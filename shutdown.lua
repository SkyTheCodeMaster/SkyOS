term.clear()
sLog.warn("SkyOS shutting down, saving and closing log")
sLog.save()
sLog.close()
os.shutdown()
