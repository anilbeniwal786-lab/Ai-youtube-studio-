import subprocess, os
from pathlib import Path

def make_silent_track(out, duration):
    Path(out).parent.mkdir(parents=True,exist_ok=True)
    subprocess.run(["ffmpeg","-y","-f","lavfi","-i",f"anullsrc=r=44100:cl=stereo",
                    "-t",str(duration),"-c:a","aac",out],check=True,capture_output=True)

def mix_audio(video, narration_files, music=None, sfx_files=None, out=None):
    """Mix narration, optional music and SFX into a final MP4."""
    out = out or str(Path(video).with_name(Path(video).stem+"_mixed.mp4"))
    inputs=["-i",video]
    tracks=[]
    for f in narration_files or []:
        if f and Path(f).exists():
            inputs += ["-i",f]; tracks.append(f"[{len(tracks)+1}:a]")
    if music and Path(music).exists():
        inputs += ["-i",music]; tracks.append(f"[{len(tracks)+1}:a]")
    for f in sfx_files or []:
        if f and Path(f).exists():
            inputs += ["-i",f]; tracks.append(f"[{len(tracks)+1}:a]")
    if not tracks:
        return video
    filt="".join(tracks)+"amix=inputs="+str(len(tracks))+":duration=longest:dropout_transition=2[a]"
    cmd=["ffmpeg","-y",*inputs,"-filter_complex",filt,"-map","0:v","-map","[a]",
         "-c:v","copy","-c:a","aac","-shortest",out]
    subprocess.run(cmd,check=True,capture_output=True)
    return out
