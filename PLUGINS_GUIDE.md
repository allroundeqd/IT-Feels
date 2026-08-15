# IT-Feels Alternate Plugin Guide

To make this app legally compliant like Stremio and Soundbound, we have decoupled the core app from any internal scraping mechanics. The application now uses a sandboxed **JavaScript Plugin Engine** (`flutter_js`) to load community plugins dynamically.

## How it works

When the app launches, it checks the app's `Documents/plugins` folder for any `.js` files. It evaluates them in a V8/QuickJS secure sandbox.

### The Plugin Sandbox

Plugins run in complete isolation. They **do not** have access to the filesystem, UI, or device hardware. 
To fetch external data securely without hitting CORS issues or requiring the plugin to do complex SSL handshakes, we expose a special `fetch` bridge to Dart.

### Writing a Plugin

Create a `my_scraper.js` file. You need to implement two global functions: `searchPlugin(query)` and `getStreamPlugin(id)`.

```javascript
// Example Plugin

function searchPlugin(query) {
    // We can call external APIs using the Dart bridge proxy
    // We use the injected `sendMessage` to communicate with the native http client.
    
    var response = sendMessage("fetch", JSON.stringify({ url: "https://api.example.com/search?q=" + query }));
    var data = JSON.parse(response);
    
    var results = [];
    for (var i = 0; i < data.items.length; i++) {
        results.push({
            id: data.items[i].id,
            title: data.items[i].title,
            artist: data.items[i].artist,
            albumArt: data.items[i].image
        });
    }
    
    return JSON.stringify(results);
}

function getStreamPlugin(id) {
    var response = sendMessage("fetch", JSON.stringify({ url: "https://api.example.com/stream/" + id }));
    var data = JSON.parse(response);
    
    // Return a direct audio URL string
    return data.streamUrl; 
}
```

The app's `AddonManager` will execute these functions dynamically whenever the user types a search query or plays a song.

## Legal Compliance

By relying strictly on this `.js` plugin engine:
- The app itself is 100% legally clean (an empty shell).
- The community can host repositories or drop `.js` files in their devices.
- No direct YouTube API evasion code is hardcoded in the app UI logic.
