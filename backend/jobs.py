import threading, uuid, traceback
JOBS={}
def start(fn,*args):
    jid=str(uuid.uuid4())
    JOBS[jid]={"job_id":jid,"status":"queued","progress":0,"message":"Queued"}
    def run():
        try:
            JOBS[jid].update(status="running",progress=5,message="Starting")
            result=fn(jid,*args)
            JOBS[jid].update(status="done",progress=100,message="Completed",result=result)
        except Exception as e:
            JOBS[jid].update(status="error",progress=100,message=str(e),error=traceback.format_exc())
    threading.Thread(target=run,daemon=True).start()
    return jid
def get(jid): return JOBS.get(jid)
