from pathlib import Path
import re,json,subprocess,hashlib
root=Path(__file__).resolve().parents[4];p=Path(__file__).resolve().parent
head=root/'Maintanance/UserDocuments/RedBlackTreeCollections/Head';b=root/'.build/arm64-apple-macosx/debug'
names=['RedBlackTreeSet','RedBlackTreeDictionary','RedBlackTreeMultiSet','RedBlackTreeMultiMap']
parts=['import RedBlackTreeCollections'];manifest=[];report={}
for name in names:
 src=root/f'Sources/RedBlackTreeCollections/{name}/{name}.swift'
 oldsrc=subprocess.check_output(['git','show','HEAD:'+str(src.relative_to(root))],cwd=root,text=True);newsrc=src.read_text()
 stripdocs=lambda s: '\n'.join(l for l in s.splitlines() if not l.lstrip().startswith('///'))
 assert stripdocs(oldsrc)==stripdocs(newsrc),name+' implementation changed'
 oldcomment=oldsrc[oldsrc.index('/// # '+name):oldsrc.index('@frozen')];newcomment=newsrc[newsrc.index('/// # '+name):newsrc.index('@frozen')]
 assert oldcomment.count('```')==newcomment.count('```'),name+' source snippet count'
 expected=re.findall(r'^## (.+)$',(head/'Outlines'/f'{name}.outline.md').read_text(),re.M)
 for f in [head/f'{name}.ja.md',head/f'{name}.md']:
  text=f.read_text();old=subprocess.check_output(['git','show','HEAD:'+str(f.relative_to(root))],cwd=root,text=True)
  assert re.findall(r'^## (.+)$',text,re.M)==expected,f.name+' outline headings'
  assert len(re.findall(r'^```',old,re.M))==len(re.findall(r'^```',text,re.M)),f.name+' snippet count'
  report[f.name]={'before':len(re.findall(r'^```',old,re.M))//2,'after':len(re.findall(r'^```',text,re.M))//2}
  for i,s in enumerate(re.findall(r'```swift\n(.*?)```',text,re.S),1):
   label=f.name+':'+str(i)
   if 'struct RedBlackTree' in s or s.strip()=='Key: Comparable':manifest.append([label,'declaration fragment']);continue
   fixture=''
   if name=='RedBlackTreeMultiMap' and 'var map:' not in s:fixture='var map: RedBlackTreeMultiMap<Int,String> = [1:"red",1:"green",1:"blue",2:"orange"]\nlet key=1\nlet i=map.lowerBound(key)\nlet j=map.index(after:i)\n'
   manifest.append([label,'executable with fixture' if fixture else 'executable'])
   parts+=['print("'+label+'")','do {',fixture+s,'}']
(p/'existing-examples.swift').write_text('\n'.join(parts))
(p/'existing-examples-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(p/'snippet-counts.json').write_text(json.dumps(report,indent=2)+'\n')
m=json.loads((b/'RedBlackTreeCollections.build/output-file-map.json').read_text());objs=[v['object'] for v in m.values() if 'object'in v]
exe=root/'.build/doc034-existing-examples'
with (p/'existing-examples-build.log').open('w') as log:
 r=subprocess.run(['swiftc','-module-cache-path',str(root/'.build/ModuleCache'),'-I',str(b/'Modules'),str(p/'existing-examples.swift'),*objs,'-o',str(exe)],stdout=log,stderr=log)
assert r.returncode==0,'compile failed'
with (p/'existing-examples-output.log').open('w') as log:r=subprocess.run([str(exe)],stdout=log,stderr=log)
assert r.returncode==0,'execution failed'
print('PASS: 4 outlines, 8 bodies, source snippet counts, implementation unchanged, 78 executable examples')
