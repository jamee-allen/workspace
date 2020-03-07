import spotipy, imp, requests, os, dotenv, base64
from bottle import route, run, request
from spotipy import oauth2
from spotipy.oauth2 import SpotifyClientCredentials
import spotipy.util as util
from dotenv import load_dotenv

load_dotenv()
PORT_NUMBER = 8080
SPOTIPY_REDIRECT_URI = 'http://localhost:8080'
SCOPE = 'user-library-read'
CACHE = '.spotipyoauthcache'
spotify_client = os.getenv("SPOTIPY_CLIENT_ID")
spotify_secret = os.getenv("SPOTIPY_CLIENT_SECRET")

sp_oauth = oauth2.SpotifyOAuth( SPOTIPY_CLIENT_ID, SPOTIPY_CLIENT_SECRET,SPOTIPY_REDIRECT_URI,scope=SCOPE,cache_path=CACHE )


token = util.oauth2.SpotifyClientCredentials(client_id=SPOTIPY_CLIENT_ID, client_secret=SPOTIPY_CLIENT_SECRET)

cache_token = token.get_access_token()
sp = spotipy.Spotify(cache_token)

#Get code


#Get auth token
auth_uri = 'https://accounts.spotify.com/api/token'
authorization = base64.standard_b64encode(spotify_client + ':' + spotify_secret)
headers = {
        'Authorization':'Basic ' + authorization
        }
data = {
        'grant_type':'authorization_code',
        'response_type':'code'}

token = requests.get(auth_uri, headers=headers, data=data)

#Get user ID
id_uri = 'https://api.spotify.com/v1/me'
requests.get(id_uri, headers={'Authorization':str(cache_token)})

#Looks for the first 10 tracks by Led Zeplin
lz_uri = 'spotify:artist:36QJpDe2go2KgaRleHCDTp'
results = sp.artist_top_tracks(lz_uri)    
for track in results['tracks'][:10]:
    print 'track    : ' + track['name']
    print 'audio    : ' + track['preview_url']
    print 'cover art: ' + track['album']['images'][0]['url']
    print

#Looks for Artist ID
name = 'Halsey'
results = sp.search(q='artist:' + name, type='artist')
items = results['artists']['items']
if len(items) > 0:
    artist = items[0]
    print artist['name'], artist['images'][0]['url']

#Lists playlists for user
playlists = sp.user_playlists('spotify')
while playlists:
    for i, playlist in enumerate(playlists['items']):
        print("%4d %s %s" % (i + 1 + playlists['offset'], playlist['uri'],  playlist['name']))
    if playlists['next']:
        playlists = sp.next(playlists)
    else:
        playlists = None

for playlist in playlists

