"""CP-20261019-006: read-only inventory of Studio data sources. Run from the repository root:
python3 -B Maintanance/Current/Evidence/CP-20261019-006/audit_sources.py
Lists every fixed server route, how many times the page template names it, and every embedded JSON seed.
A route the page never names is either used by other clients (comm.py, tests) or unused by the page."""
import re, ast
from pathlib import Path
app = Path('Maintanance/RegistryApp')
serve = (app / 'serve.py').read_text()
page = (app / 'index.template.html').read_text()
get = re.search(r'GET_ROUTES = \{(.*?)\n\}', serve, re.S)[1]
post = re.search(r'POST_ACTIONS = \{(.*?)\}', serve, re.S)[1]
routes = sorted(set(re.findall(r"'(/[a-z\-.]*)'\s*:", get)) | set(re.findall(r"'(/[a-z\-]+)'\s*:", post)))
routes += ['/letters', '/letters-inbox', '/letters/<id>']
# the page builds '/activity-'+kind for kind in a literal list
kinds = ast.literal_eval(re.search(r"for\(const kind of (\[[^\]]*\])\)", page)[1])
built = {'/activity-' + k for k in kinds}
for r in routes:
    key = r.replace('<id>', '')
    n = sum(page.count(q + key) for q in "'\"`") + (1 if r in built else 0)
    if r == '/letters':
        n = page.count("'/letters?")
    print(f'{n:2}  {r}')
print('seeds:', re.findall(r'<script id="([^"]+)" type="application/json"', page))
print('activity kinds read by the page:', kinds)
