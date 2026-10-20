// @section tabs
// User (2026-10-19, OPS-136): the header switches between the work area (left, shown first) and the task area (#workspace). Both stay
// in the DOM, so selections and inputs survive the round trip and polling keeps both up to date.
const AREA_TABS = [['work', 'workArea'], ['task', 'workspace']];
function switchArea(name) { for (const [n, id] of AREA_TABS) { const on = n === name; $(id).hidden = !on; const tab = $(n + 'AreaTab'); tab.setAttribute('aria-selected', String(on)); tab.tabIndex = on ? 0 : -1; } }
for (const [name] of AREA_TABS) { const tab = $(name + 'AreaTab'), names = AREA_TABS.map(a => a[0]); tab.onclick = () => switchArea(name); tab.onkeydown = e => { if (['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(e.key)) { e.preventDefault(); let i = names.indexOf(name); i = e.key === 'Home' ? 0 : e.key === 'End' ? names.length - 1 : (i + (e.key === 'ArrowRight' ? 1 : names.length - 1)) % names.length; switchArea(names[i]); $(names[i] + 'AreaTab').focus(); } }; }

// @endsection
// @section layout
// OPS-126: only the title/actions row (and the canonical-change notice) is sticky. Keep the scroll padding equal to its
// measured height so scrollIntoView and keyboard focus land below it, following wrapped buttons and the notice opening.
// OPS-126 proposal 7: on narrow screens these rows scroll sideways; show a keyboard-focused control fully (Chromium
// otherwise leaves the last button partly outside). Only when the row actually overflows.
if (typeof document !== 'undefined' && document.querySelectorAll) for (const row of document.querySelectorAll('header .header-row,header .header-approval,.buttons[role=tablist]')) row.addEventListener('focusin', e => { if (row.scrollWidth > row.clientWidth && e.target.scrollIntoView) e.target.scrollIntoView({ block: 'nearest', inline: 'nearest' }); });
// OPS-136: the top-left menu. The button toggles the list; Esc (from the button or the list) closes it and returns focus to
// the button; a click outside closes it. Choosing an action closes it after that action's own click handling, so the file
// picker, confirm() and dialogs work as before; focus goes back to the button only if it was left in the list or nowhere.
// Disabled (busy) actions show on the button. The open state is DOM only; polling never touches it.
function createHeaderMenu({ button, menu, root, defer = fn => setTimeout(fn, 0) }) {
    const setOpen = open => { menu.hidden = !open; button.setAttribute('aria-expanded', String(open)); };
    const close = refocus => { if (menu.hidden) return; setOpen(false); if (refocus) button.focus(); };
    button.addEventListener('click', () => setOpen(menu.hidden));
    for (const node of [button, menu]) node.addEventListener('keydown', e => { if (e.key === 'Escape' && !menu.hidden) { e.preventDefault(); close(true); } });
    menu.addEventListener('keydown', e => { const file = e.target.closest?.('label.file'); if (file && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); file.querySelector('input').click(); } });
    menu.addEventListener('click', e => { if (!e.target.closest?.('button,label')) return; defer(() => { const a = root.activeElement; close(!a || a === root.body || menu.contains(a)); }); });
    root.addEventListener('click', e => { if (!menu.hidden && !menu.contains(e.target) && !button.contains(e.target)) close(false); });
    // Both labels share one grid cell (CSS), so the button keeps its width while busy; only which label is visible changes.
    const busy = () => { const on = [...menu.querySelectorAll('button')].some(b => b.disabled); button.setAttribute('aria-busy', String(on)); };
    return { close, busy, setOpen };
}

// @endsection
// @section bindings
// OPS-136: when focus leaves the scrolled approval part, it returns to its start so the state is visible again.
if (typeof document !== 'undefined' && document.querySelector) { const part = document.querySelector('header .header-approval'); if (part) part.addEventListener('focusout', e => { if (!part.contains(e.relatedTarget)) part.scrollLeft = 0; }); }
if (typeof document !== 'undefined' && document.getElementById && document.getElementById('headerMenuButton')) { const menu = createHeaderMenu({ button: $('headerMenuButton'), menu: $('headerMenu'), root: document }); if (typeof MutationObserver !== 'undefined') new MutationObserver(menu.busy).observe($('headerMenu'), { subtree: true, attributes: true, attributeFilter: ['disabled'] }); }
if (typeof ResizeObserver !== 'undefined') { const stickyHeader = document.querySelector('header'), fitStickyHeight = () => document.documentElement.style.setProperty('--sticky-h', Math.ceil(stickyHeader.getBoundingClientRect().height) + 'px'); new ResizeObserver(fitStickyHeight).observe(stickyHeader); fitStickyHeight(); }



// @endsection
