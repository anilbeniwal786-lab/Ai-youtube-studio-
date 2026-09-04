import os, base64
from pathlib import Path

def generate_thumbnail(project_id, title, visual_hint="cinematic realistic 3D YouTube thumbnail"):
    out=Path(os.getenv("DATA_DIR","./data"))/f"{project_id}_thumbnail.png"
    if os.getenv("MOCK_MODE","true").lower()=="true":
        # Reuse first scene image when available; otherwise create a tiny valid PNG.
        scene=out.parent/f"{project_id}_scene_1.png"
        if scene.exists(): out.write_bytes(scene.read_bytes())
        else: out.write_bytes(base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="))
        return str(out)
    from openai import OpenAI
    key=os.getenv("OPENAI_API_KEY","").strip()
    if not key: raise RuntimeError("OPENAI_API_KEY is missing")
    client=OpenAI(api_key=key)
    prompt=f"Create a high-click-through YouTube thumbnail for: {title}. {visual_hint}. 16:9, dramatic lighting, clear focal subject, no tiny text, no watermark."
    result=client.images.generate(model=os.getenv("OPENAI_IMAGE_MODEL","gpt-image-2"),prompt=prompt,size="1536x1024")
    out.write_bytes(base64.b64decode(result.data[0].b64_json))
    return str(out)
