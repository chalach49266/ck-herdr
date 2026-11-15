import json, os, sys
from pathlib import Path
e=json.load(sys.stdin)
p=Path(__file__).resolve().parent.parent/'events.jsonl'
with p.open('a') as f:
    f.write(json.dumps({'event':sys.argv[1],'status':e.get('status'),'cwd':os.getcwd(),'hc_present':bool(os.environ.get('HC_TERMINAL_ID'))})+'\n')
print(json.dumps({'continue':True} if sys.argv[1]=='beforeSubmitPrompt' else {}))
