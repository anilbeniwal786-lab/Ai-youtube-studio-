import os
from pathlib import Path
SCOPES=['https://www.googleapis.com/auth/youtube.upload']
def _creds():
    from google_auth_oauthlib.flow import InstalledAppFlow
    from google.oauth2.credentials import Credentials
    token=Path(os.getenv('YOUTUBE_TOKEN_FILE','youtube_token.json')); secret=os.getenv('GOOGLE_CLIENT_SECRETS','client_secret.json')
    creds=Credentials.from_authorized_user_file(str(token),SCOPES) if token.exists() else None
    if not creds or not creds.valid:
        flow=InstalledAppFlow.from_client_secrets_file(secret,SCOPES); creds=flow.run_local_server(port=int(os.getenv('YOUTUBE_OAUTH_PORT','8090'))); token.write_text(creds.to_json())
    return creds

def service():
    from googleapiclient.discovery import build
    return build('youtube','v3',credentials=_creds())

def upload(video_path,title,description='',tags=None,privacy=None,category_id='22',thumbnail_path=None,caption_path=None):
    from googleapiclient.http import MediaFileUpload
    yt=service(); body={'snippet':{'title':title[:100],'description':description[:5000],'tags':(tags or [])[:500],'categoryId':category_id},'status':{'privacyStatus':privacy or os.getenv('YOUTUBE_PRIVACY_STATUS','private')}}
    response=yt.videos().insert(part='snippet,status',body=body,media_body=MediaFileUpload(video_path,mimetype='video/mp4',resumable=True)).execute(); vid=response.get('id'); thumb=False; cap=False
    if thumbnail_path and Path(thumbnail_path).exists(): yt.thumbnails().set(videoId=vid,media_body=MediaFileUpload(thumbnail_path,mimetype='image/png')).execute(); thumb=True
    if caption_path and Path(caption_path).exists():
        from googleapiclient.http import MediaFileUpload
        from googleapiclient.model import JsonModel
        yt.captions().insert(part='snippet',body={'snippet':{'videoId':vid,'language':'hi','name':'Hindi','isDraft':False}},media_body=MediaFileUpload(caption_path,mimetype='application/octet-stream')).execute(); cap=True
    return {'video_id':vid,'url':f'https://www.youtube.com/watch?v={vid}','thumbnail_set':thumb,'captions_uploaded':cap}
