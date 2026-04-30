import sys
from ytmusicapi import YTMusic

def init_ytmusic():
    """Create a YTMusic instance – use auth file if present."""
    try:
        return YTMusic('headers_auth.json')
    except Exception:
        return YTMusic()

def search_track(query, ytm):
    """Return the first matching track's videoId."""
    results = ytm.search(query, filter='songs')
    if not results:
        return None
    return results[0].get('videoId')

def get_related_playlist(video_id, ytm):
    related = ytm.get_watch_playlist(video_id, limit=2, radio=True)
    if not related:
        raise ValueError("No related songs found.")
    return related


def main():
    if len(sys.argv) < 2:
        print("Provide a search query, e.g. 'LOGE – own it'")
        sys.exit(1)

    query = " ".join(sys.argv[1:])
    ytm = init_ytmusic()
    video_id = search_track(query, ytm)

    if not video_id:
        print("No track found.")
        sys.exit(1)
    playlist_data = get_related_playlist(video_id, ytm)
    playlist = []
    for track in playlist_data["tracks"]:
        playlist.append({
            "artist": track['artists'][0]['name'],
            "title": track['title'],
            "videoId": track['videoId'],
            "url": f"https://www.youtube.com/watch?v={track['videoId']}"
        })
    res = "\n".join(f"(:artist \"{pl['artist']}\" :title \"{pl['title']}\" :videoId \"{pl['videoId']}\" :url \"{pl['url']}\")" for pl in playlist)
    print(f"(setq *playlist-tracks* '({res}))")


if __name__ == "__main__":
    main()
