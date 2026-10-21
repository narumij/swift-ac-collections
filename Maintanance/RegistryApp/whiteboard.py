"""Ephemeral shared drawing, coordinates in a 1200 by 700 board."""
from threading import RLock
from copy import deepcopy
import math
from task_state import TaskState

class Whiteboard(TaskState):
    def __init__(self):
        super().__init__()
        self._edit = RLock()
        self.update({'width':1200, 'height':700, 'items':[]})

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
        else: raise ValueError('Unknown board item')
        with self._edit:
            state = self.snapshot()
            items = state['document']['items']
            for old in items:
                if old['id']==item['id']:
                    if old != item: raise ValueError('Item id already used')
                    return state
            if len(items)>=2000: raise ValueError('Prototype board is full')
            items.append(item)
            return self.update({**state['document'],'items':items})

board = Whiteboard()
