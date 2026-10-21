// @section timeline
function startNotificationTimeline(box, status) {
  if (!box || !status) return;
  const stream = new EventSource('/notifications/timeline');
  let entries = [];
  stream.onopen = () => { status.textContent = '受信中 · 直近100行＋新着（最大500件）'; };
  stream.onmessage = event => {
    const follow = box.scrollHeight - box.scrollTop - box.clientHeight < 24;
    const value = JSON.parse(event.data);
    entries = (value.reset ? value.entries : entries.concat(value.entries)).slice(-500);
    box.textContent = entries.join('\n');
    if (follow) box.scrollTop = box.scrollHeight;
  };
  stream.onerror = () => { status.textContent = '再接続中 · 表示を保持し、接続後にログから補います'; };
  stream.addEventListener('overflow', () => {
    stream.close();
    status.textContent = '受信が追いつかず停止しました · 再読み込みしてください（通知の欠落あり）';
  });
  window.addEventListener('pagehide', () => stream.close());
}
// @endsection
