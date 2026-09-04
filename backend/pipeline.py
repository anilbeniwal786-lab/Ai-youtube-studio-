from pathlib import Path
from render import render_project
from providers import generate_scene_assets
from thumbnail import generate_thumbnail
from captions import make_srt
from audio_assets import ensure_audio
import os


def run_pipeline(jid, pid, project, aspect_ratio='9:16', make_thumbnail=True):
    # Caller updates the in-memory project after this returns.
    scenes = project.get('scenes', [])
    if not scenes:
        raise RuntimeError('Project has no scenes')
    data = Path(os.getenv('DATA_DIR', './data')); data.mkdir(parents=True, exist_ok=True)
    total = len(scenes)
    assets = []
    for i, scene in enumerate(scenes, 1):
        image = __import__('providers').generate_image(pid, scene, project.get('style','realistic_3d'))
        audio = __import__('providers').generate_tts(pid, scene)
        assets.append({'scene': scene['scene'], 'image': image, 'audio': audio, 'video': None,
                       'camera': scene.get('camera','slow push-in'), 'sfx': scene.get('sfx',''),
                       'music': ensure_audio(pid,'sfx',i) if scene.get('sfx') else None})
        from jobs import JOBS
        JOBS[jid].update(progress=max(5, int(i/total*55)), message=f'Assets {i}/{total}')
    project['assets'] = assets
    project['captions'] = make_srt(pid, scenes)
    project['aspect_ratio'] = aspect_ratio
    if make_thumbnail:
        project['thumbnail'] = generate_thumbnail(pid, project.get('title','AI Video'))
        JOBS[jid].update(progress=65, message='Thumbnail ready')
    music = ensure_audio(pid,'music',0)
    output = render_project(str(data/f'{pid}.mp4'), assets, aspect_ratio, music=music, captions=project.get('captions'), burn_captions=os.getenv('BURN_CAPTIONS','true').lower()=='true')
    JOBS[jid].update(progress=95, message='Final video rendered')
    return {'file': output, 'thumbnail': project.get('thumbnail'), 'captions': project.get('captions'), 'assets': assets}
