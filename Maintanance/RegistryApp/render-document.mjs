// Render one observed Markdown document with the same renderer used by the bundle.
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
const {marked} = await import(process.argv[2] ? pathToFileURL(path.resolve(process.argv[2])).href : 'marked');
process.stdout.write(marked.parse(fs.readFileSync(0, 'utf8')));
