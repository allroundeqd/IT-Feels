const BACKEND_URL = "https://it-feels-backend.cleverfox687.workers.dev"; // Live Cloudflare Worker URL

// Return the direct search API endpoint
function getSearchUrl(query) {
    return BACKEND_URL + "/api/v1/search?query=" + encodeURIComponent(query);
}

function getSearchPlaylistsUrl(query) {
    return BACKEND_URL + "/api/v1/search/playlists?query=" + encodeURIComponent(query);
}

function getSearchPodcastsUrl(query) {
    return BACKEND_URL + "/api/v1/search/podcasts?query=" + encodeURIComponent(query);
}

// Return the direct stream API endpoint
function getStreamUrl(id, query) {
    if (query) {
        return BACKEND_URL + "/api/v1/video/stream?id=" + encodeURIComponent(id) + "&query=" + encodeURIComponent(query);
    }
    return BACKEND_URL + "/api/v1/video/stream?id=" + encodeURIComponent("search:" + id);
}

function getHomeFeedUrl() {
    return BACKEND_URL + "/api/v1/saavn/home";
}

function getPlaylistTracksUrl(id) {
    return BACKEND_URL + "/api/v1/saavn/playlist?id=" + encodeURIComponent(id);
}

function getAlbumTracksUrl(id) {
    return BACKEND_URL + "/api/v1/saavn/album?id=" + encodeURIComponent(id);
}

function getChartsUrl() {
    return BACKEND_URL + "/api/v1/charts/trending";
}

function getTrendingVideosUrl() {
    return BACKEND_URL + "/api/v1/videos/trending";
}
