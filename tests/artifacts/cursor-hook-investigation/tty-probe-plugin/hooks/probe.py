import json,os,sys
from pathlib import Path
json.load(sys.stdin)
e={'event':'sessionStart','hc_present':bool(os.environ.get('HC_TERMINAL_ID'))}
try:
    fd=os.open('/dev/tty',os.O_WRONLY)
    e['tty_open']=True
    os.close(fd)
except OSError as error:
    e['tty_open']=False
    e['tty_error']=str(error)
(Path(__file__).resolve().parent.parent/'event.json').write_text(json.dumps(e,indent=2)+'\n')
print('{}')
