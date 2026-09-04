import os, math, wave, struct
from pathlib import Path

def tone(path, seconds=1.0, freq=440):
    path=Path(path); rate=44100; n=int(rate*seconds)
    with wave.open(str(path),'w') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(rate)
        for i in range(n):
            v=int(9000*math.sin(2*math.pi*freq*i/rate)); w.writeframes(struct.pack('<h',v))
    return str(path)

def ensure_audio(project_id, kind, index):
    data=Path(os.getenv('DATA_DIR','./data')); data.mkdir(parents=True,exist_ok=True)
    if os.getenv('MOCK_MODE','true').lower()=='true': return tone(data/f'{project_id}_{kind}_{index}.wav',0.5,330+index*30)
    return None
