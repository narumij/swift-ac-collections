// OPS-126 proposals 1-2: only the title/actions row and the canonical-change notice stay sticky; the note, the current
// work line and the activity band scroll normally; the scroll padding follows the measured sticky height. Static checks.
const fs=require('fs'),assert=require('assert');
const html=fs.readFileSync(__dirname+'/index.template.html','utf8');
const header=html.slice(html.indexOf('<header>'),html.indexOf('</header>'));
const infoStart=html.indexOf('<section class="header-info"'),info=html.slice(infoStart,html.indexOf('</section></section>',infoStart)+20);
assert(infoStart===html.indexOf('</header>')+'</header>'.length,'the scrolling info section follows the sticky header directly');
for(const id of ['save','open','changes','refresh','restart','canonicalNotice','canonicalSummary'])assert(header.includes('id="'+id+'"'),id+' stays in the sticky header');
for(const id of ['activity-current-heading','activity-current-detail','activity-events','activity-events-status'])assert(!header.includes('id="'+id+'"')&&info.includes('id="'+id+'"'),id+' moved to the scrolling section');
assert(!header.includes('class="header-note"')&&info.includes('class="header-note"'),'the note scrolls');
for(const id of ['activity-current-heading','activity-events','save','canonicalNotice'])assert.equal(html.split('id="'+id+'"').length,2,'exactly one '+id);
assert(html.includes('header{position:sticky;top:0;'),'the header is still sticky');
assert(!/\.header-info\{[^}]*position:sticky/.test(html),'the info section is not sticky');
assert(html.includes('html{scroll-padding-top:var(--sticky-h,0px)}'),'scroll padding uses the measured height');
assert(/new ResizeObserver\(fitStickyHeight\)\.observe\(stickyHeader\)/.test(html),'the height follows wrapping and the notice');
assert(!/scrollTo\(|scrollBy\(/.test(html.slice(html.indexOf('// OPS-126: only the title/actions row'),html.indexOf('// OPS-126: only the title/actions row')+600)),'no automatic scroll correction');
assert(html.indexOf('class="approval-lane')>html.indexOf('</header>'),'the work lane stays outside the sticky header');
console.log('PASS: OPS-126 header layout (sticky title/actions + notice only; note, current work and activity band scroll; measured scroll padding).');
