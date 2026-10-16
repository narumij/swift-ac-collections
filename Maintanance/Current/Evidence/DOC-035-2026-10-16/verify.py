from pathlib import Path
import re, json, subprocess, hashlib
root=Path(__file__).resolve().parents[4]; out=Path(__file__).resolve().parent
mods=['AcCollections','NextPermutationModule','OptionalElementBufferModule','ElementBufferModule']
files=[root/f'Sources/{m}/{m}.docc/{m}.md' for m in mods]
files += [root/'Sources/ElementBufferModule/ElementBuffer.swift']
manifest=[]; parts=['import AcCollections']
for f in files:
 text=f.read_text()
 if f.suffix=='.swift':text='\n'.join(re.sub(r'^\s*/// ?', '', l) for l in text.splitlines() if l.lstrip().startswith('///'))
 for i,code in enumerate(re.findall(r'```swift\n(.*?)```',text,re.S),1):
  label=str(f.relative_to(root))+':'+str(i)
  code=code.replace('import AcCollections','')
  # Assertions supplement existing examples; they are not inserted in public documentation.
  if 'let value =' in code:
   code=re.sub(r'(let value = .*?// (42|3))',lambda m:m[1]+'\nprecondition(value == '+m[2]+')',code)
  parts += ['do {',code,'}']
  manifest.append(label)
(out/'existing-examples.swift').write_text('\n'.join(parts))
b=root/'.build/arm64-apple-macosx/release';objs=[]
for m in mods+['RedBlackTreeCollections']:
 mapping=json.loads((b/f'{m}.build/output-file-map.json').read_text())
 objs += [v['object'] for k,v in mapping.items() if k and 'object' in v]
exe=root/'.build/doc035-examples'
with (out/'examples-build.log').open('w') as log:
 r=subprocess.run(['swiftc','-module-cache-path',str(root/'.build/ModuleCache'),'-I',str(b/'Modules'),str(out/'existing-examples.swift'),*objs,'-o',str(exe)],stdout=log,stderr=log)
assert r.returncode==0,'compile failed'
r=subprocess.run([str(exe)],capture_output=True,text=True)
(out/'examples-output.log').write_text(r.stdout+r.stderr)
assert r.returncode==0
assert r.stdout.strip().splitlines()==['[2, 1, 3]','[2, 3, 1]','[3, 1, 2]','[3, 2, 1]'],r.stdout
counts={}
for f in files+[root/'README.md',root/'README.ja.md',root/'Sources/OptionalElementBufferModule/OptionalElementBuffer.swift']:
 rel=str(f.relative_to(root));old=subprocess.check_output(['git','show','HEAD:'+rel],cwd=root,text=True)
 assert old.count('```')==f.read_text().count('```'),rel
 counts[rel]=f.read_text().count('```')//2
for name in ['Sources/OptionalElementBufferModule/OptionalElementBuffer.swift']:
 old=subprocess.check_output(['git','show','HEAD:'+name],cwd=root,text=True)
 strip=lambda t:'\n'.join(l for l in t.splitlines() if not l.lstrip().startswith('///'))
 assert strip(old)==strip((root/name).read_text())
# Prior accepted red-black source/docs are unchanged; reuse its 78-example evidence.
r=subprocess.run(['git','diff','--exit-code','f6e181b2','--','Sources/RedBlackTreeCollections','Maintanance/UserDocuments/RedBlackTreeCollections/Head'],cwd=root,capture_output=True,text=True)
assert r.returncode==0,'RBT input changed'
for f in [root/'README.md',root/'README.ja.md']:
 for link in re.findall(r'\]\((Sources/[^)]+)\)',f.read_text()):assert (root/link).is_file(),link
(out/'verification.json').write_text(json.dumps({'examples':manifest,'snippetCounts':counts,'rbtPriorEvidence':'DOC-034: 78 examples, source unchanged since f6e181b2','checks':'compile/run, stated values and output, snippet counts, documentation-only source change, README source links'},ensure_ascii=False,indent=2)+'\n')
inputs=[root/'Package.swift',root/'Sources/AcCollections/AcCollections.swift',root/'README.md',root/'README.ja.md']
for mod in mods+['RedBlackTreeCollections']:
 inputs+=list((root/'Sources'/mod).rglob('*.swift'))+list((root/'Sources'/mod).rglob('*.docc/*.md'))
(out/'input-sha256.json').write_text(json.dumps({str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest() for f in inputs},indent=2)+'\n')
print('PASS:',len(manifest),'existing examples; RBT 78-example evidence reused; snippet counts unchanged')
