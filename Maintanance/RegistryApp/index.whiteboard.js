// @section main
(() => {
  const board = $('whiteboard-canvas'), status = $('board-status');
  const ns = 'http://www.w3.org/2000/svg';
  let mode = 'stroke', online = false, drawing = null, current = [], revision = -1;
  function shape(item) {
    const node = document.createElementNS(ns, item.kind === 'text' ? 'text' : 'polyline');
    if (item.kind === 'text') { node.setAttribute('x',item.x);node.setAttribute('y',item.y);node.setAttribute('font-size','22');node.setAttribute('dominant-baseline','hanging');node.textContent=item.text; }
    else {node.setAttribute('points',item.points.map(p=>p.join(',')).join(' '));node.setAttribute('fill','none');node.setAttribute('stroke','#000');node.setAttribute('stroke-width','3');node.setAttribute('stroke-linecap','round');node.setAttribute('stroke-linejoin','round');}
    return node;
  }
  function draw() {board.replaceChildren(...current.map(shape)); if(drawing) board.append(shape(drawing));}
  function receive(snapshot) {if(snapshot.revision < revision)return;revision=snapshot.revision;current=snapshot.document.items;draw();}
  function setMode(next) {mode=next;$('board-pen').setAttribute('aria-pressed',String(next==='stroke'));$('board-text').setAttribute('aria-pressed',String(next==='text'));}
  $('board-pen').onclick=()=>setMode('stroke');$('board-text').onclick=()=>{setMode('text');$('board-text-input').focus();};
  function point(e) {const p=new DOMPoint(e.clientX,e.clientY).matrixTransform(board.getScreenCTM().inverse());return [Math.max(0,Math.min(1200,p.x)),Math.max(0,Math.min(700,p.y))];}
  async function send(item) {
    status.textContent='共有中…';
    try { const response=await fetch('/whiteboard',{method:'POST',headers:{'Content-Type':'application/json','X-Registry-Studio':'whiteboard'},body:JSON.stringify(item)});
      const data=await response.json();if(!response.ok)throw Error(data.error || '送信失敗');receive(data);status.textContent='共有中';
    } catch(error) {status.textContent='共有できませんでした：'+error.message;}
  }
  $('board-clear').onclick=()=>{drawing=null;setMode('stroke');draw();send({action:'clear'});};
  board.onpointerdown=e=>{if(!online||e.button!==0)return;e.preventDefault();const p=point(e);
    if(mode==='text'){const text=$('board-text-input').value;if(text.trim())send({id:crypto.randomUUID(),kind:'text',x:p[0],y:p[1],text});else status.textContent='配置する文字を入力してください';return;}
    drawing={id:crypto.randomUUID(),kind:'stroke',points:[p]};board.setPointerCapture(e.pointerId);draw();};
  board.onpointermove=e=>{if(drawing&&drawing.points.length<10000){drawing.points.push(point(e));draw();}};
  board.onpointerup=e=>{if(!drawing)return;const item=drawing;drawing=null;if(item.points.length===1)item.points.push([Math.min(1200,item.points[0][0]+0.1),item.points[0][1]]);draw();send(item);};
  board.onpointercancel=()=>{drawing=null;draw();};
  let source;
  function connect(){source=new EventSource('/whiteboard/events');source.onmessage=e=>{const data=JSON.parse(e.data);if(!online)revision=-1;online=true;receive(data);status.textContent='共有中';};source.onerror=()=>{online=false;status.textContent='未接続 · 再接続中';};}
  connect();window.addEventListener('pagehide',()=>source.close());window.addEventListener('pageshow',e=>{if(e.persisted)connect();});
})();
// @endsection
