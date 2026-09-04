import os, base64, json, uuid
from pathlib import Path
from dotenv import load_dotenv
load_dotenv()

DATA = Path(os.getenv("DATA_DIR","./data"))
DATA.mkdir(parents=True, exist_ok=True)
MOCK = os.getenv("MOCK_MODE","true").lower() == "true"

def _openai():
    from openai import OpenAI
    key = os.getenv("OPENAI_API_KEY","").strip()
    if not key:
        raise RuntimeError("OPENAI_API_KEY is missing")
    return OpenAI(api_key=key)

def story_plan(topic, mode="short", language="hi", style="realistic_3d"):
    count = 5 if mode == "short" else 10
    if MOCK:
        return {
            "title": topic[:80],
            "description": f"{topic} — AI YouTube Studio Phase 5",
            "tags": [x for x in topic.split() if x][:8],
            "language": language, "mode": mode, "style": style,
            "scenes": [{
                "scene": i+1, "duration": 5 if mode=="short" else 7,
                "narration": f"{topic} — दृश्य {i+1}: कहानी आगे बढ़ती है और नया मोड़ आता है।",
                "visual_prompt": f"cinematic realistic 3D animation, {topic}, scene {i+1}, consistent characters, natural lighting",
                "camera": "slow push-in" if i%2==0 else "tracking shot",
                "sfx": "cinematic whoosh"
            } for i in range(count)]
        }

    client = _openai()
    prompt = f"""Create a production-ready Hindi YouTube video plan.
Topic: {topic}
Format: {mode}
Visual style: {style}
Return ONLY valid JSON with:
title, description, tags (array), scenes (array of exactly {count} items).
Each scene must contain scene, duration, narration, visual_prompt, camera, sfx.
Keep narration natural for Hindi voice-over. Make visual prompts detailed and maintain character consistency."""
    r = client.responses.create(
        model=os.getenv("OPENAI_TEXT_MODEL","gpt-5.6-luna"),
        input=prompt
    )
    text = r.output_text.strip()
    if text.startswith("```"):
        text = text.strip("`")
        if text.startswith("json"):
            text = text[4:]
    return json.loads(text)

def generate_image(project_id, scene, style="realistic_3d"):
    out = DATA / f"{project_id}_scene_{scene['scene']}.png"
    if MOCK:
        # 1x1 transparent PNG placeholder
        out.write_bytes(base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="))
        return str(out)

    client = _openai()
    prompt = scene["visual_prompt"] + f", {style}, 16:9 cinematic composition, no text, high detail"
    result = client.images.generate(
        model=os.getenv("OPENAI_IMAGE_MODEL","gpt-image-2"),
        prompt=prompt,
        size="1536x1024"
    )
    b64 = result.data[0].b64_json
    out.write_bytes(base64.b64decode(b64))
    return str(out)

def generate_tts(project_id, scene):
    out = DATA / f"{project_id}_scene_{scene['scene']}.mp3"
    if MOCK:
        return None
    client = _openai()
    with client.audio.speech.with_streaming_response.create(
        model=os.getenv("OPENAI_TTS_MODEL","gpt-4o-mini-tts"),
        voice=os.getenv("OPENAI_TTS_VOICE","alloy"),
        input=scene["narration"],
        response_format="mp3"
    ) as response:
        response.stream_to_file(out)
    return str(out)

def generate_scene_assets(project_id, scenes, style):
    assets=[]
    for scene in scenes:
        assets.append({
            "scene": scene["scene"],
            "image": generate_image(project_id, scene, style),
            "audio": generate_tts(project_id, scene),
            "video": None,
            "camera": scene.get("camera","slow push-in"),
            "sfx": scene.get("sfx","")
        })
    return assets
