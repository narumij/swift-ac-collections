import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath,pathToFileURL} from 'node:url';
const {marked}=await import(process.argv[2]?pathToFileURL(path.resolve(process.argv[2])).href:'marked');
const here=path.dirname(fileURLToPath(import.meta.url)),root=path.resolve(here,'../..');
const output=process.env.REGISTRY_STUDIO_APP||path.resolve(here,'../Cache/RegistryStudio');
const data=JSON.parse(fs.readFileSync(path.join(output,'registry.json'),'utf8'));
const refs=new Set([data.source.path,...(data.extraDocuments||[])].filter(r=>/\.md$/.test(r)));  // V3 (OPS-167 B4): source.path is v3-db; extraDocuments names the Registry view
for(const t of [...data.tasks,...(data.milestones||[])])for(const m of t.detail.matchAll(/(?:Maintanance|Sources|Tests)\/[^`\s|]+?\.md/g))refs.add(m[0]);
const files={},missing=[];
for(const ref of refs){const full=path.resolve(root,ref);if(!fs.existsSync(full)){missing.push(ref);continue;}if(!fs.realpathSync(full).startsWith(root+path.sep))throw Error('Path outside repository');const md=fs.readFileSync(full,'utf8');files[ref]={html:marked.parse(md),sha256:crypto.createHash('sha256').update(md).digest('hex')};}
const bundle={generatedAt:new Date().toISOString(),files,missing};
const tag='<script id="documents" type="application/json">'+JSON.stringify(bundle).replaceAll('<','\\u003c')+'</script>';
const target=path.join(output,'index.html');let html=fs.readFileSync(target,'utf8');html=html.includes('<script id="documents"')?html.replace(/<script id="documents"[\s\S]*?<\/script>/,()=>tag):html.replace('<script>\n',tag+'\n<script>\n');const pendingMatch=html.match(/<script id="pendingSeed" type="application\/json">([\s\S]*?)<\/script>/);
if(pendingMatch){const pending=JSON.parse(pendingMatch[1]);for(const entry of pending.entries)entry.html=marked.parse(entry.raw);html=html.replace(/<script id="pendingSeed"[\s\S]*?<\/script>/,()=>'<script id="pendingSeed" type="application/json">'+JSON.stringify(pending).replaceAll('<','\\u003c')+'</script>');}
fs.writeFileSync(target,html);console.log(`Bundled ${Object.keys(files).length} documents; missing: ${missing.join(', ')||'none'}`);
