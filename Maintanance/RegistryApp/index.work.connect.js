// @section connect
// The page's one studio: the activity timeline with its current band, the work cards, the member status, 待機完了 and letters.
function workLaneInstance() {
  if (!workLaneInstance.value) {
    const states = new Map(JSON.parse($('seed').textContent).tasks.map(t => [t.id, t.state])), make = tag => document.createElement(tag), select = $('wake-owner');
    const studio = workLaneInstance.value = createStudio({
      registryState: id => states.get(id), views: {
        timeline: createActivityTimelineView($('activity-events'), $('activity-events-status'), make, () => document.activeElement, { heading: $('activity-current-heading'), detail: $('activity-current-detail') }),
        cards: createWorkLaneView({ track: $('work-lane-track'), status: $('work-lane-status'), makeNode: make, getActive: () => document.activeElement }),
        members: createMemberLampView({ box: $('presence-lamps'), makeNode: make }),
        wake: createWakeView({ select, button: $('wake-send'), status: $('wake-status'), onChange: () => studio.wakeSelect(select.value), onClick: () => studio.wakeSend(sendWake) }),
        letters: createLettersView({
          list: $('letters-list'), detail: $('letters-detail'), status: $('letters-status'), member: $('letters-member'), state: $('letters-state'), older: $('letters-older'), latest: $('letters-latest'), makeNode: make,
          onSelect: id => { studio.letterSelect(id); letterPolls.detail(); }, onFilter: patch => { studio.letterFilter(patch); letterPolls.list(); }, onPage: cursor => { studio.letterPage(cursor); letterPolls.list(); }
        })
      }
    });
    // OPS-156 H-20261019-32: the letters are read with GET only, one request at a time per kind; a detail answer names its letter.
    const letterPolls = createLetterPolls({ studio, fetchJson: async path => { const controller = new AbortController(), timer = setTimeout(() => controller.abort(), 5000); try { const response = await fetch(path, { cache: 'no-store', signal: controller.signal }); if (!response.ok) throw Error('unavailable'); return await response.json(); } finally { clearTimeout(timer); } } });
    // OPS-141: continuity marks feed the same snapshot (5 s fetch, paused while the page is hidden); the clock is an input every second.
    if (typeof location !== 'undefined' && location.protocol !== 'file:' && typeof fetch === 'function') {
      const memberEvents = new EventSource('/members/events');
      memberEvents.onmessage = event => {
        try {
          const model = JSON.parse(event.data);
          if (!Array.isArray(model.members) || model.members.some(m => typeof m.owner !== 'string' || !['present', 'absent'].includes(m.attendance))) throw Error('Invalid members');
          studio.input({ source: 'members', ok: true, value: model, at: Date.now() });
        } catch (_) { studio.input({ source: 'members', ok: false, at: Date.now() }); }
      };
      memberEvents.onerror = () => studio.input({ source: 'members', ok: false, at: Date.now() });
      window.addEventListener('pagehide', () => memberEvents.close());
      window.addEventListener('pageshow', event => { if (event.persisted) window.location.reload(); });
      const status = createContinuityStatus({ onData: data => studio.continuity(data, performance.now()), fetchRecord: async () => { const controller = new AbortController(), timer = setTimeout(() => controller.abort(), 4000); try { const response = await fetch('/continuity', { cache: 'no-store', signal: controller.signal }); if (!response.ok) throw Error('unavailable'); return await response.json(); } finally { clearTimeout(timer); } } });
      status.poll(); setInterval(() => { if (!document.hidden) status.poll(); }, 5000); setInterval(() => studio.tick(performance.now()), 1000);
      letterPolls.list(); setInterval(() => { if (!document.hidden) { letterPolls.list(); letterPolls.detail(); } }, 5000); document.addEventListener('visibilitychange', () => { if (!document.hidden) { status.poll(); studio.tick(performance.now()); } });
    }
  }
  return workLaneInstance.value;
}


// @endsection
