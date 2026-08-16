import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:it_feels_music/data/models/song_model.dart';
import 'package:it_feels_music/services/storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';

class CloudSyncService {
  final FirebaseFirestore _firestore;
  final DatabaseService _dbService;
  StreamSubscription? _connectivitySubscription;
  bool _isFlushing = false;
  StreamSubscription? _favoritesSubscription;

  CloudSyncService({FirebaseFirestore? firestore, DatabaseService? dbService}) 
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _dbService = dbService ?? DatabaseService();

  // Initialize Sync Listeners if user is logged in
  void initializeSync(User user) {
    pullCloudUpdates(user.uid);
    flushDirtyFavorites(user.uid);
    
    // Background Worker: flush when network restored
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        flushDirtyFavorites(user.uid);
      }
    });
  }

  void stopSync() {
    // No long-lived subscription in Phase 2 boot sequence
    _connectivitySubscription?.cancel();
  }

  // ----------------------------------------------------
  // Push (Local -> Cloud) Event-Driven
  // ----------------------------------------------------
  Future<void> pushMutation(String uid, Song song, {bool isDeleted = false}) async {
    try {
      final docRef = _firestore.collection('users').doc(uid).collection('favorites').doc(song.id);
      
      final payload = _songToMap(song);
      payload['is_deleted'] = isDeleted;
      payload['updated_at'] = FieldValue.serverTimestamp();

      await docRef.set(payload, SetOptions(merge: true));
      
      // If successful, ensure it's marked clean locally
      if (song.isDirty) {
        song.isDirty = false;
        await _dbService.saveSong(song);
      }
    } catch (e) {
      debugPrint('[CloudSyncService] Error pushing mutation (offline?): $e');
      song.isDirty = true;
      await _dbService.saveSong(song);
    }
  }

  Future<void> flushDirtyFavorites(String uid) async {
    if (_isFlushing) return;
    _isFlushing = true;
    try {
      final dirtySongs = await _dbService.getAllDirtySongs();
      if (dirtySongs.isEmpty) return;

      final batch = _firestore.batch();
      final favoritesRef = _firestore.collection('users').doc(uid).collection('favorites');

      for (var song in dirtySongs) {
        final docRef = favoritesRef.doc(song.id);
        final payload = _songToMap(song);
        payload['is_deleted'] = !song.isFavorite; 
        payload['updated_at'] = FieldValue.serverTimestamp();
        batch.set(docRef, payload, SetOptions(merge: true));
      }

      await batch.commit();
      
      for (var song in dirtySongs) {
        song.isDirty = false;
        await _dbService.saveSong(song);
      }
      debugPrint('[CloudSyncService] Flushed ${dirtySongs.length} dirty favorites to cloud.');
    } catch (e) {
      debugPrint('[CloudSyncService] Error flushing dirty records: $e');
    } finally {
      _isFlushing = false;
    }
  }

  // ----------------------------------------------------
  // Pull (Cloud -> Local) Boot Sequence
  // ----------------------------------------------------
  Future<void> pullCloudUpdates(String uid) async {
    try {
      int currentLastSync = await StorageService.getLastSyncTimestamp();
      bool hasMore = true;
      int totalPulled = 0;

      while (hasMore) {
        final snapshot = await _firestore
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .where('updated_at', isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(currentLastSync))
            .orderBy('updated_at')
            .limit(500)
            .get();

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        int highestTimestamp = currentLastSync;

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final bool isDeleted = data['is_deleted'] == true;
          
          final ts = data['updated_at'] as Timestamp?;
          if (ts != null && ts.millisecondsSinceEpoch > highestTimestamp) {
            highestTimestamp = ts.millisecondsSinceEpoch;
          }

          final songId = data['id'] ?? doc.id;
          
          if (isDeleted) {
            // Untoggle favorite
            final localSong = await _dbService.getSong(songId);
            if (localSong != null) {
              localSong.isFavorite = false;
              localSong.isDirty = false;
              await _dbService.saveSong(localSong);
            }
          } else {
            // Upsert to Isar
            final cloudSong = _mapToSong(data, doc.id);
            cloudSong.isFavorite = true;
            cloudSong.isDirty = false; // It came from cloud, it's clean
            await _dbService.saveSong(cloudSong);
          }
        }

        await StorageService.setLastSyncTimestamp(highestTimestamp);
        currentLastSync = highestTimestamp;
        totalPulled += snapshot.docs.length;

        if (snapshot.docs.length < 500) {
          hasMore = false;
        }
      }

      if (totalPulled > 0) {
        debugPrint('[CloudSyncService] Pulled $totalPulled delta updates from cloud in total.');
      }
    } catch (e) {
      debugPrint('[CloudSyncService] Error pulling cloud updates: $e');
    }
  }

  // ----------------------------------------------------
  // Helpers
  // ----------------------------------------------------
  Map<String, dynamic> _songToMap(Song song) {
    return {
      'id': song.id,
      'saavnId': song.saavnId,
      'title': song.title,
      'artist': song.artist,
      'album': song.album,
      'coverArt': song.coverArt,
      'duration': song.duration,
      'hasLyrics': song.hasLyrics,
      // Note: 'timestamp' removed, using updated_at and is_deleted at operation level
    };
  }

  Song _mapToSong(Map<String, dynamic> data, String docId) {
    return Song(
      id: data['id'] ?? docId,
      saavnId: data['saavnId'] ?? docId.replaceFirst('saavn:', ''),
      title: data['title'] ?? 'Unknown',
      artist: data['artist'] ?? 'Unknown',
      album: data['album'] ?? 'Unknown',
      coverArt: data['coverArt'] ?? '',
      duration: data['duration'] ?? 0,
      hasLyrics: data['hasLyrics'] ?? false,
      addedAt: DateTime.now(),
      isFavorite: true,
      searchVector: Song.generateSearchVector(
        data['title'] ?? '',
        data['artist'] ?? '',
        data['album'] ?? '',
      )
    );
  }
}
