# Phase 9.5 replacement backend main.py
# This file keeps the existing API routes and adds /generate-media for OpenAI Images + Hindi TTS.
import os, uuid, base64
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import httpx
from providers import story_plan, generate_scene_assets
from jobs import start,get
from render import render_project
from youtube_upload import upload as youtube_upload
from thumbnail import generate_thumbnail
from pipeline import run_pipeline
load_dotenv()
app=FastAPI(title='AI YouTube Studio Phase 9.5')
DATA=Path(os.getenv('DATA_DIR','./data')); DATA.mkdir(parents=True,exist_ok=True)
MEDIA=DATA/'media'; MEDIA.mkdir(parents=True,exist_ok=True)
app.mount('/media',StaticFiles(directory=str(MEDIA)),name='media')
PROJECTS={}
class Plan(BaseModel): topic:str; mode:str='short'; language:str='hi'; style:str='realistic_3d'
class Assets(BaseModel): style:str='realistic_3d'; aspect_ratio:str='9:16'
class Render(BaseModel): project_id:str; aspect_ratio:str='9:16'
class Thumb(BaseModel): project_id:str
class Upload(BaseModel): project_id:str; privacy:str='private'; category_id:str='22'; upload_captions:bool=True
class Pipeline(BaseModel): project_id:str; aspect_ratio:str='9:16'; make_thumbnail:bool=True
class Metadata(BaseModel): title:str|None=None; description:str|None=None; tags:list[str]|None=None
@app.get('/api/health')
def health(): return {'ok':True,'phase':9.5,'mock_mode':os.getenv('MOCK_MODE','true').lower()=='true','openai_configured':bool(os.getenv('OPENAI_API_KEY')),'youtube_configured':Path(os.getenv('GOOGLE_CLIENT_SECRETS','client_secret.json')).exists()}
@app.get('/health')
def health_simple(): return {'status':'ok','openai_configured':bool(os.getenv('OPENAI_API_KEY'))}
@app.post('/api/project/plan')
def plan(x:Plan):
    pid=str(uuid.uuid4()); p=story_plan(x.topic,x.mode,x.language,x.style); p.update(style=x.style,assets=[]); PROJECTS[pid]=p; return {'project_id':pid,**p}
@app.get('/api/project/{pid}')
def project(pid:str):
    if pid not in PROJECTS: raise HTTPException(404,'Project not found')
    return {'project_id':pid,**PROJECTS[pid]}
@app.post('/api/project/{pid}/assets')
def assets(pid:str,x:Assets):
    if pid not in PROJECTS: raise HTTPException(404,'Project not found')
    a=generate_scene_assets(pid,PROJECTS[pid]['scenes'],x.style); PROJECTS[pid].update(assets=a,aspect_ratio=x.aspect_ratio); return {'project_id':pid,'assets':a}
def public_url(path):
    base=os.getenv('PUBLIC_BASE_URL','').rstrip('/'); return f'{base}{path}' if base else path
@app.post('/generate-media')
async def generate_media(project:dict):
    key=os.getenv('OPENAI_API_KEY')
    if not key: raise HTTPException(500,'OPENAI_API_KEY is not configured')
    scenes=project.get('scenes') or []
    if not scenes: raise HTTPException(400,'No scenes found in project')
    headers={'Authorization':f'Bearer {key}'}
    async with httpx.AsyncClient(timeout=180) as client:
        for i,scene in enumerate(scenes,1):
            narration=str(scene.get('narration','')); dialogue=str(scene.get('dialogue',scene.get('dialogues','')))
            prompt=('Create a cinematic vertical 9:16 scene for a Hindi YouTube story. No text, no subtitles, no watermark. Keep recurring characters visually consistent. Scene description: '+narration)
            if dialogue: prompt+=' Characters/dialogue context: '+dialogue
            r=await client.post('https://api.openai.com/v1/images/generations',headers=headers,json={'model':os.getenv('IMAGE_MODEL','gpt-image-1'),'prompt':prompt[:10000],'size':'1024x1536','quality':'medium','output_format':'jpeg'})
            if r.status_code>=300: raise HTTPException(502,f'Image API error: {r.text[:1000]}')
            b64=r.json().get('data',[{}])[0].get('b64_json')
            if not b64: raise HTTPException(502,'Image API returned no image data')
            img=MEDIA/f'scene_{i}_{uuid.uuid4().hex[:8]}.jpg'; img.write_bytes(base64.b64decode(b64)); scene['image_url']=public_url(f'/media/{img.name}')
            text=(narration+'\n\n'+dialogue if dialogue else narration)[:4096]
            r=await client.post('https://api.openai.com/v1/audio/speech',headers=headers,json={'model':os.getenv('TTS_MODEL','gpt-4o-mini-tts'),'voice':os.getenv('TTS_VOICE','marin'),'input':text,'instructions':'Speak natural, clear Hindi for a YouTube story. Use expressive storytelling and natural pauses.','response_format':'mp3'})
            if r.status_code>=300: raise HTTPException(502,f'TTS API error: {r.text[:1000]}')
            audio=MEDIA/f'scene_{i}_{uuid.uuid4().hex[:8]}.mp3'; audio.write_bytes(r.content); scene['audio_url']=public_url(f'/media/{audio.name}')
    return project
def do_render(jid,pid,aspect):
    p=PROJECTS[pid]
    if not p.get('assets'): raise RuntimeError('Generate assets first')
    return {'file':render_project(str(DATA/f'{pid}.mp4'),p['assets'],aspect)}
@app.post('/api/render')
def render(x:Render):
    if x.project_id not in PROJECTS: raise HTTPException(404,'Project not found')
    return {'job_id':start(do_render,x.project_id,x.aspect_ratio)}
@app.get('/api/jobs/{jid}')
def job(jid:str):
    j=get(jid)
    if not j: raise HTTPException(404,'Job not found')
    return j
@app.get('/api/render/{pid}/file')
def file(pid:str):
    p=DATA/f'{pid}.mp4'
    if not p.exists(): raise HTTPException(404,'Video not ready')
    return FileResponse(p,media_type='video/mp4',filename=f'{pid}.mp4')
@app.post('/api/project/{pid}/thumbnail')
def thumbnail(pid:str,x:Thumb):
    if pid not in PROJECTS: raise HTTPException(404,'Project not found')
    path=generate_thumbnail(pid,PROJECTS[pid].get('title','AI Video')); PROJECTS[pid]['thumbnail']=path; return {'project_id':pid,'thumbnail':path}
@app.get('/api/project/{pid}/thumbnail/file')
def thumbnail_file(pid:str):
    p=DATA/f'{pid}_thumbnail.png'
    if not p.exists(): raise HTTPException(404,'Thumbnail not ready')
    return FileResponse(p,media_type='image/png',filename=f'{pid}_thumbnail.png')
@app.patch('/api/project/{pid}/metadata')
def metadata(pid:str,x:Metadata):
    if pid not in PROJECTS: raise HTTPException(404,'Project not found')
    p=PROJECTS[pid]
    if x.title is not None: p['title']=x.title[:100]
    if x.description is not None: p['description']=x.description[:5000]
    if x.tags is not None: p['tags']=x.tags[:500]
    return {'project_id':pid,'title':p.get('title'),'description':p.get('description'),'tags':p.get('tags',[])}
def do_pipeline(jid,pid,aspect,make_thumb): return run_pipeline(jid,pid,PROJECTS[pid],aspect,make_thumb)
@app.post('/api/pipeline')
def pipeline(x:Pipeline):
    if x.project_id not in PROJECTS: raise HTTPException(404,'Project not found')
    return {'job_id':start(do_pipeline,x.project_id,x.aspect_ratio,x.make_thumbnail)}
@app.get('/api/project/{pid}/captions/file')
def captions_file(pid:str):
    p=DATA/f'{pid}.srt'
    if not p.exists(): raise HTTPException(404,'Captions not ready')
    return FileResponse(p,media_type='application/x-subrip',filename=f'{pid}.srt')
@app.get('/api/youtube/status')
def youtube_status():
    secret=Path(os.getenv('GOOGLE_CLIENT_SECRETS','client_secret.json')); token=Path(os.getenv('YOUTUBE_TOKEN_FILE','youtube_token.json')); return {'client_configured':secret.exists(),'authorized':token.exists()}
@app.post('/api/youtube/upload')
def yt_upload(x:Upload):
    if x.project_id not in PROJECTS: raise HTTPException(404,'Project not found')
    video=DATA/f'{x.project_id}.mp4'
    if not video.exists(): raise HTTPException(400,'Render the video first')
    p=PROJECTS[x.project_id]; thumb=p.get('thumbnail')
    try: return youtube_upload(str(video),p.get('title','AI Video'),p.get('description',''),p.get('tags',[]),x.privacy,x.category_id,thumb,p.get('captions') if x.upload_captions else None)
    except Exception as e: raise HTTPException(500,f'YouTube upload failed: {e}')
