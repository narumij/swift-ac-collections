let graphZoom = 100;
function applyGraphZoom() {
  const box = $('graph'), s = box.querySelector('svg');
  if (s) { const values = s.getAttribute('viewBox').split(/\s+/).map(Number); s.setAttribute('width', values[2] * graphZoom / 100); s.setAttribute('height', values[3] * graphZoom / 100); }
  $('graphZoomReset').textContent = graphZoom + '%';
  $('graphZoomOut').disabled = graphZoom <= 25; $('graphZoomIn').disabled = graphZoom >= 200;
}
function setGraphZoom(value) {
  const next = Math.max(25, Math.min(200, Math.round(value))); if (!Number.isFinite(next)) return;
  const box = $('graph'), ratio = next / graphZoom;
  const x = (box.scrollLeft + box.clientWidth / 2) * ratio - box.clientWidth / 2;
  const y = (box.scrollTop + box.clientHeight / 2) * ratio - box.clientHeight / 2;
  graphZoom = next; applyGraphZoom(); box.scrollLeft = Math.max(0, x); box.scrollTop = Math.max(0, y); $('graphTip').hidden = true;
}
$('graphZoomOut').onclick = () => setGraphZoom(graphZoom - 25);
$('graphZoomIn').onclick = () => setGraphZoom(graphZoom + 25);
$('graphZoomReset').onclick = () => setGraphZoom(100);
$('graphHoverEnabled').onchange = () => { $('graphTip').hidden = true; };
// OPS-126: the card explanation is fixed to the viewport, so close it as soon as the page scrolls instead of waiting
// for the browser's synthetic pointer event (about 50-100 ms later in headless WebKit/Chromium).
if (typeof window !== 'undefined') window.addEventListener('scroll', () => { $('graphTip').hidden = true; }, { passive: true });

