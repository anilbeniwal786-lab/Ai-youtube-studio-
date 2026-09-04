from pathlib import Path

def _ts(sec):
    ms=int(round(sec*1000)); h=ms//3600000; ms%=3600000; m=ms//60000; ms%=60000; s=ms//1000; ms%=1000
    return f'{h:02d}:{m:02d}:{s:02d},{ms:03d}'

def make_srt(project_id, scenes):
    out=Path(__import__('os').getenv('DATA_DIR','./data'))/f'{project_id}.srt'; t=0.0; rows=[]
    for i,s in enumerate(scenes,1):
        d=float(s.get('duration',5)); rows += [str(i), f'{_ts(t)} --> {_ts(t+d)}', s.get('narration','').strip(), '']; t+=d
    out.write_text('\n'.join(rows),encoding='utf8'); return str(out)
