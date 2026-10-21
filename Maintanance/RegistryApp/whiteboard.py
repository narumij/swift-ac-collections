"""Ephemeral shared drawing, coordinates in a 1200 by 700 board."""
from threading import RLock
from copy import deepcopy
import math
import base64
import binascii
from task_state import TaskState

class Whiteboard(TaskState):
    def __init__(self):
        super().__init__()
        self._edit = RLock()
        self.update({'width':1200, 'height':700, 'items':[]})

    def clear(self):
        with self._edit:
            state = self.snapshot()
            return self.update({**state['document'], 'items': []})

    def add(self, item):
        item = deepcopy(item)
        if not isinstance(item, dict) or not isinstance(item.get('id'),str) or not 1 <= len(item['id']) <= 100:
            raise ValueError('An item id is required')
        def coordinate(value, limit):
            if isinstance(value,bool) or not isinstance(value,(int,float)) or not math.isfinite(value) or not 0 <= value <= limit:
                raise ValueError('Invalid board coordinate')
        if item.get('kind') == 'stroke' and set(item) == {'id','kind','points'}:
            if not isinstance(item['points'],list) or not 1 <= len(item['points']) <= 10000:
                raise ValueError('A stroke needs 1 to 10000 points')
            for point in item['points']:
                if not isinstance(point,list) or len(point)!=2: raise ValueError('Invalid point')
                coordinate(point[0],1200);coordinate(point[1],700)
        elif item.get('kind') == 'text' and set(item) == {'id','kind','x','y','text'}:
            coordinate(item['x'],1200);coordinate(item['y'],700)
            if not isinstance(item['text'],str) or not item['text'].strip() or len(item['text'])>2000:
                raise ValueError('Text needs 1 to 2000 characters')
        elif item.get('kind') == 'image' and set(item) == {'id','kind','x','y','width','height','src'}:
            coordinate(item['x'],1200);coordinate(item['y'],700)
            coordinate(item['width'],1200);coordinate(item['height'],700)
            if item['width'] <= 0 or item['height'] <= 0: raise ValueError('Invalid image size')
            src = item['src']
            if not isinstance(src,str) or not src.startswith('data:image/png;base64,') or len(src)>6*1024*1024:
                raise ValueError('Expected PNG image up to 6 MiB')
            try: raw=base64.b64decode(src.split(',',1)[1],validate=True)
            except (ValueError,binascii.Error): raise ValueError('Invalid image data')
            if not raw.startswith(b'\x89PNG\r\n\x1a\n'): raise ValueError('Invalid PNG image')
        else: raise ValueError('Unknown board item')
        with self._edit:
            state = self.snapshot()
            items = state['document']['items']
            for old in items:
                if old['id']==item['id']:
                    if old != item: raise ValueError('Item id already used')
                    return state
            if item['kind']=='image': items=[old for old in items if old['kind']!='image']
            if len(items)>=2000: raise ValueError('Prototype board is full')
            if item['kind']=='image': items.insert(0,item)
            else: items.append(item)
            return self.update({**state['document'],'items':items})

board = Whiteboard()
