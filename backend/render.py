import os, subprocess
from pathlib import Path

def _run(cmd): subprocess.run(cmd, check=True, capture_output=True)

def render_project(out, assets, aspect='9:16', music=None, captions=None, burn_captions=False):
    Path(out).parent.mkdir(parents=True,exist_ok=True); w,h=(1080,1920) if aspect=='9:16' else (1920,1080)
    valid=[a for a in assets if a.get('image') and Path(a['image']).exists()]
    if not valid: _run(['ffmpeg','-y','-f','lavfi','-i',f'color=c=black:s={w}x{h}:d=10','-c:v','libx264','-pix_fmt','yuv420p',out]); return out
    segs=[]
    for i,a in enumerate(valid):
        audio=a.get('audio'); d=5.0
        if audio and Path(audio).exists():
            try: d=float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','default=noprint_wrappers=1:nokey=1',audio],text=True).strip())
            except: pass
        d=max(2,min(30,d)); seg=Path(out).with_name(f'.seg_{i}.mp4'); vf=f'scale={w}:{h}:force_original_aspect_ratio=increase,crop={w}:{h},zoompan=z=\'min(zoom+0.0008,1.12)\':d=1:s={w}x{h}:fps=30'
        cmd=['ffmpeg','-y','-loop','1','-i',a['image']]
        if audio and Path(audio).exists(): cmd += ['-i',audio,'-t',str(d),'-vf',vf,'-c:v','libx264','-c:a','aac','-shortest','-pix_fmt','yuv420p',str(seg)]
        else: cmd += ['-t',str(d),'-vf',vf,'-c:v','libx264','-pix_fmt','yuv420p',str(seg)]
        _run(cmd); segs.append(seg)
    lst=Path(out).with_suffix('.concat.txt'); lst.write_text('\n'.join(f"file '{s.as_posix()}'" for s in segs),encoding='utf8')
    base=Path(out).with_name(out.replace('.mp4','_base.mp4')); _run(['ffmpeg','-y','-f','concat','-safe','0','-i',str(lst),'-c','copy',str(base)])
    final_input=str(base)
    if music and Path(music).exists():
        mixed=Path(out).with_name(out.replace('.mp4','_mix.mp4'))
        _run(['ffmpeg','-y','-i',str(base),'-stream_loop','-1','-i',music,'-filter_complex','[1:a]volume=0.16[m];[0:a][m]amix=inputs=2:duration=first:dropout_transition=2[a]','-map','0:v','-map','[a]','-c:v','copy','-c:a','aac','-shortest',str(mixed)]); final_input=str(mixed)
    if burn_captions and captions and Path(captions).exists():
        cap=Path(captions).as_posix().replace(':','\\:')
        _run(['ffmpeg','-y','-i',final_input,'-vf',f"subtitles={cap}:force_style='FontSize=18,Outline=2'",'-c:v','libx264','-c:a','copy',out])
    else: _run(['ffmpeg','-y','-i',final_input,'-c','copy',out])
    for p in segs+[lst,base]:
        try: Path(p).unlink()
        except: pass
    return out
