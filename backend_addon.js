// IT-Feels Provider Backend Addon
// This script acts as a bridge between the app and your custom Dart backend.
// Place this file in your App Documents /plugins directory.

// Change this to your deployed backend URL, or leave as localhost for testing
const BACKEND_URL = "http://127.0.0.1:8080";

function searchPlugin(query) {
    var response = sendMessage("fetch", JSON.stringify({ 
        url: BACKEND_URL + "/api/v1/search?query=" + encodeURIComponent(query) 
    }));
    
    if (!response) return JSON.stringify([]);
    
    var data = JSON.parse(response);
    if (!data.success || !data.results) return JSON.stringify([]);
    
    var mappedResults = [];
    for (var i = 0; i < data.results.length; i++) {
        var item = data.results[i];
        mappedResults.push({
            id: item.id,
            title: item.title,
            artist: item.artist,
            album: item.album,
            albumArt: item.coverArt
        });
    }
    
    return JSON.stringify(mappedResults);
}

function getStreamPlugin(id) {
    // Note: the backend stream handler accepts an 'id' or a 'query' to search YouTube.
    // If we only have a Saavn ID, we might need to pass the query string instead of id,
    // because the backend handles Saavn IDs by doing a YouTube search via the `query` param if it starts with 'search:'.
    
    var response = sendMessage("fetch", JSON.stringify({ 
        url: BACKEND_URL + "/api/v1/video/stream?id=" + encodeURIComponent("search:" + id) 
    }));
    
    if (!response) return null;
    
    var data = JSON.parse(response);
    if (data.success && data.audioUrl) {
        return data.audioUrl;
    }
    
    return null;
}
