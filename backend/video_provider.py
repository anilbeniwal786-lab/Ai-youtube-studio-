import os, requests
from pathlib import Path

class VideoProvider:
    """Adapter interface for a real image-to-video provider."""
    def generate(self, image_path, prompt, duration=5, aspect="9:16"):
        raise NotImplementedError

class HttpVideoProvider(VideoProvider):
    """Generic async REST adapter. Configure URL/token for your chosen provider."""
    def __init__(self):
        self.url=os.getenv("VIDEO_API_URL","").strip()
        self.token=os.getenv("VIDEO_API_TOKEN","").strip()
    def generate(self, image_path, prompt, duration=5, aspect="9:16"):
        if not self.url or not self.token:
            return None
        with open(image_path,"rb") as f:
            r=requests.post(self.url,headers={"Authorization":f"Bearer {self.token}"},
                            files={"image":f},data={"prompt":prompt,"duration":duration,"aspect":aspect},timeout=120)
        r.raise_for_status()
        data=r.json()
        return data.get("video_url")

def provider():
    return HttpVideoProvider()
