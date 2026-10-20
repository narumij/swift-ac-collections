"""Task-thread turns: ordered discussion, NOP, and explicitly approved skips.
Speech and NOP do not imply receipt, approval, or task completion.
The trial_* table names are retained for compatibility with existing records.
"""
import hashlib
import json
import uuid
import approvals
from studio_store import Store

class TaskRoundStore(Store):
    def setup(self, c):
        c.execute('CREATE TABLE IF NOT EXISTS trial_anchors(round_id TEXT PRIMARY KEY, letter_id TEXT NOT NULL UNIQUE REFERENCES letters(id))')
        c.execute('CREATE TABLE IF NOT EXISTS trial_rounds(id TEXT PRIMARY KEY, task TEXT NOT NULL, members TEXT NOT NULL)')
        c.execute('CREATE TABLE IF NOT EXISTS trial_turns(round_id TEXT NOT NULL REFERENCES trial_rounds(id), turn INTEGER NOT NULL, actor TEXT NOT NULL, kind TEXT NOT NULL, letter_id TEXT REFERENCES letters(id), at TEXT NOT NULL, PRIMARY KEY(round_id,turn))')
        c.execute('CREATE TABLE IF NOT EXISTS trial_members(sequence INTEGER PRIMARY KEY AUTOINCREMENT, round_id TEXT NOT NULL REFERENCES trial_rounds(id), member TEXT NOT NULL, operation_id TEXT NOT NULL REFERENCES operations(id), at TEXT NOT NULL, UNIQUE(round_id,member))')
        c.execute('CREATE TABLE IF NOT EXISTS trial_next(round_id TEXT NOT NULL REFERENCES trial_rounds(id), turn INTEGER NOT NULL, speaker TEXT NOT NULL, PRIMARY KEY(round_id,turn))')
        c.execute('CREATE TABLE IF NOT EXISTS trial_skip_policy(sequence INTEGER PRIMARY KEY AUTOINCREMENT, round_id TEXT NOT NULL, member TEXT NOT NULL, enabled INTEGER NOT NULL, reason TEXT NOT NULL, operation_id TEXT NOT NULL, at TEXT NOT NULL)')
        for table in ('trial_anchors','trial_skip_policy','trial_rounds','trial_turns','trial_members','trial_next'):
            for op in ('UPDATE','DELETE'):
                c.execute(f"CREATE TRIGGER IF NOT EXISTS retain_{table}_{op} BEFORE {op} ON {table} BEGIN SELECT RAISE(ABORT,'append only'); END")

    def snapshot(self,c,rid):
        r=c.execute('SELECT * FROM trial_rounds WHERE id=?',(rid,)).fetchone()
        if not r: raise LookupError('Unknown round')
        original=json.loads(r['members'])
        members=original+[x[0] for x in c.execute('SELECT member FROM trial_members WHERE round_id=? ORDER BY sequence',(rid,))]
        turns=[dict(x) for x in c.execute('SELECT * FROM trial_turns WHERE round_id=? ORDER BY turn',(rid,))]
        for t in turns:
            if t['kind']=='skip':
                row=c.execute("SELECT result FROM operations WHERE kind='round-trial' AND json_extract(result,'$.round')=? AND json_extract(result,'$.completedTurn')=?",(rid,t['turn'])).fetchone()
                if row:t.update({k:v for k,v in json.loads(row[0]).items() if k in ('skipped','skippedBy','reason','approval')})
        current=c.execute('SELECT speaker FROM trial_next WHERE round_id=? AND turn=?',(rid,len(turns))).fetchone()
        speaker=current[0] if current else original[len(turns)%len(original)]
        policies={}
        for x in c.execute('SELECT * FROM trial_skip_policy WHERE round_id=? ORDER BY sequence',(rid,)):policies[x['member']]=dict(x)
        active={k:v for k,v in policies.items() if v['enabled']}
        out={'continuousSkips':active,'policyRevision':max([x['sequence'] for x in policies.values()],default=0),'paused':all(x in active for x in members),'id':rid,'task':r['task'],'members':members,'turn':len(turns),'speaker':speaker,'history':turns}
        # Immutable letter text is part of the read boundary, not just turn count.
        out['texts']=[{'id':t['letter_id'],'text':self._letter(c,t['letter_id'])} for t in turns if t['letter_id']]
        anchor=c.execute('SELECT letter_id FROM trial_anchors WHERE round_id=?',(rid,)).fetchone()
        out['anchor']=self._letter(c,anchor[0])
        link=c.execute('SELECT thread_id FROM letter_links WHERE letter_id=?',(anchor[0],)).fetchone()
        out['threadId']=link[0] if link else anchor[0]
        out['blocked']=out['anchor']['state'] in ('withdrawn','stopped','closed','declined','returned')
        out['canonical']={'doc':out['anchor']['request']['ref_doc'],'section':out['anchor']['request']['ref_section']}
        out['context']=hashlib.sha256(json.dumps(out,sort_keys=True,ensure_ascii=False).encode()).hexdigest()
        return out

    def advance_skipped(self,c,rid):
        # At most one circuit. All suspended: retain position and wait for release.
        snap=self.snapshot(c,rid)
        for _ in snap['members']:
            if snap['paused'] or snap['speaker'] not in snap['continuousSkips']:break
            policy=snap['continuousSkips'][snap['speaker']]
            op=uuid.uuid4().hex
            result={'round':rid,'completedTurn':snap['turn'],'skipped':snap['speaker'],'skippedBy':'Server','reason':policy['reason'],'approval':policy['operation_id']}
            self._record_operation(c,op,'round-trial',{'automaticSkip':result},'Server','applied',result)
            c.execute('INSERT INTO trial_turns VALUES (?,?,?,?,?,?)',(rid,snap['turn'],'Server','skip',None,approvals.now()))
            nxt=snap['members'][(snap['members'].index(snap['speaker'])+1)%len(snap['members'])]
            c.execute('INSERT INTO trial_next VALUES (?,?,?)',(rid,snap['turn']+1,nxt))
            snap=self.snapshot(c,rid)
        return snap

    def rounds_for_letter(self,letter_id):
        with self.transaction() as c:
            self.setup(c)
            self._letter(c,letter_id)
            row=c.execute('SELECT thread_id FROM letter_links WHERE letter_id=?',(letter_id,)).fetchone()
            root=row[0] if row else letter_id
            anchors=c.execute('SELECT a.round_id FROM trial_anchors a LEFT JOIN letter_links l ON l.letter_id=a.letter_id WHERE COALESCE(l.thread_id,a.letter_id)=?',(root,)).fetchall()
            return [self.snapshot(c,a[0]) for a in anchors]

    def show_round(self,rid):
        with self.transaction() as c:
            self.setup(c)
            return self.snapshot(c,rid)

    def act(self,b):
        if not isinstance(b,dict): raise ValueError('Expected object')
        action=b.get('action'); actor=b.get('actor');op=b.get('operationId')
        approvals.text(actor,80)
        if not isinstance(op,str) or not approvals.OPERATION_ID.fullmatch(op): raise ValueError('operationId required')
        if action=='create':
            if set(b)!={'action','actor','operationId','members','letter'}:raise ValueError('Unexpected fields')
            m=b['members']
            if not isinstance(m,list) or not 2<=len(m)<=8 or len(set(m))!=len(m):raise ValueError('2..8 unique members')
            for x in m:approvals.text(x,80)
            approvals.text(b['letter'],80)
        elif action=='add-member':
            if set(b)!={'action','actor','operationId','round','turn','member'}:raise ValueError('Unexpected fields')
            approvals.text(b['member'],80)
            if type(b['turn']) is not int or b['turn']<0:raise ValueError('Expected turn number')
            # Checked against the request sender inside the transaction.
        elif action=='continuous-skip':
            if set(b)!={'action','actor','operationId','round','context','target','enabled','reason'}:raise ValueError('Unexpected fields')
            if actor!='User':raise approvals.Conflict('User approval required')
            if type(b['enabled']) is not bool:raise ValueError('enabled must be boolean')
            approvals.text(b['reason']);approvals.text(b['target'],80)
        elif action=='approve-skip':
            if set(b)!={'action','actor','operationId','round','turn','target','reason'}:raise ValueError('Unexpected fields')
            if actor!='User':raise approvals.Conflict('User approval required')
            approvals.text(b['reason']);approvals.text(b['target'],80)
        elif action=='skip':
            if set(b)!={'action','actor','operationId','round','turn','reason','approval'}:raise ValueError('Unexpected fields')
            approvals.text(b['reason'])
            if type(b['turn']) is not int or b['turn']<0:raise ValueError('Expected turn number')
            # Checked against the request sender inside the transaction.
        elif action in ('speak','nop'):
            required={'action','actor','operationId','round','turn','context'}|({'body'} if action=='speak' else set())
            if set(b)!=required:raise ValueError('Unexpected fields')
            if type(b['turn']) is not int or b['turn']<0:raise ValueError('Expected turn number')
            if action=='speak':approvals.text(b['body'])
        else:raise ValueError('Unknown action')
        with self.transaction() as c:
            self.setup(c)
            previous=self._operation(c,op,'round-trial',b)
            if previous:return previous['result']|{'replayed':True}
            if action=='create':
                anchor=self._letter(c,b['letter'])
                if actor!=anchor['sender']:raise approvals.Conflict('Only request sender enables turns')
                if anchor['sender'] not in m or anchor['recipient'] not in m:raise ValueError('Include request sender and recipient')
                if anchor['kind']!='request' or anchor['state'] not in ('sent','received','started'):raise approvals.Conflict('Request is not open')
                if not anchor['request']['ref_doc']:raise ValueError('Request must reference its canonical document')
                if c.execute('SELECT 1 FROM trial_anchors WHERE letter_id=?',(b['letter'],)).fetchone():raise approvals.Conflict('Already has turns')
                rid='RND-'+uuid.uuid4().hex.upper()
                c.execute('INSERT INTO trial_rounds VALUES (?,?,?)',(rid,anchor['taskId'],json.dumps(m)))
                c.execute('INSERT INTO trial_anchors VALUES (?,?)',(rid,b['letter']))
                result=self.snapshot(c,rid)
                self._record_operation(c,op,'round-trial',b,actor,'applied',result)
                return result
            snap=self.snapshot(c,b['round'])
            if snap['blocked']:raise approvals.Conflict('Request is returned, closed or stopped; do not continue turns')
            if action in ('add-member','skip') and actor!=snap['anchor']['sender']:raise approvals.Conflict('Only request sender controls turns')
            if action=='continuous-skip':
                if b['context']!=snap['context']:raise approvals.Conflict('Stale approval context')
                if b['target'] not in snap['members']:raise approvals.Conflict('Unknown member')
                if (b['target'] in snap['continuousSkips'])==b['enabled']:raise approvals.Conflict('Already in requested state')
                c.execute('INSERT INTO trial_skip_policy(round_id,member,enabled,reason,operation_id,at) VALUES (?,?,?,?,?,?)',(b['round'],b['target'],int(b['enabled']),b['reason'],op,approvals.now()))
                result=self.advance_skipped(c,b['round'])
                self._record_operation(c,op,'round-trial',b,actor,'applied',result)
                return result
            if action in ('speak','nop','skip') and snap['paused']:raise approvals.Conflict('All participants suspended')
            if action=='approve-skip':
                if type(b['turn']) is not int or b['turn']!=snap['turn'] or b['target']!=snap['speaker']:raise approvals.Conflict('Stale approval target')
                result={'approval':op,'round':b['round'],'turn':b['turn'],'target':b['target'],'reason':b['reason'],'approvedBy':'User'}
                self._record_operation(c,op,'round-trial',b,actor,'applied',result)
                return result
            if action in ('speak','nop') and b['context']!=snap['context']:raise approvals.Conflict('Read current context before responding')
            if action=='skip':
                row=c.execute("SELECT result FROM operations WHERE id=? AND actor='User' AND kind='round-trial'",(b['approval'],)).fetchone()
                approved=json.loads(row[0]) if row else {}
                if any(approved.get(k)!=v for k,v in {'round':b['round'],'turn':b['turn'],'target':snap['speaker'],'reason':b['reason'],'approvedBy':'User'}.items()):raise approvals.Conflict('Matching user approval required')
            if action=='add-member':
                if b['turn']!=snap['turn']:raise approvals.Conflict('Stale turn')
                if b['member'] in snap['members']:raise approvals.Conflict('Already a member')
                if len(snap['members'])>=8:raise approvals.Conflict('Round member limit')
                result={'round':b['round'],'members':snap['members']+[b['member']],'turn':snap['turn'],'speaker':snap['speaker']}
                self._record_operation(c,op,'round-trial',b,actor,'applied',result)
                c.execute('INSERT INTO trial_members(round_id,member,operation_id,at) VALUES (?,?,?,?)',(b['round'],b['member'],op,approvals.now()))
                self.advance_skipped(c,b['round'])
                return result
            if b['turn']!=snap['turn'] or (action!='skip' and actor!=snap['speaker']):raise approvals.Conflict('Not this turn or speaker')
            lid='LTR-'+__import__('datetime').datetime.now().strftime('%Y%m%d')+'-'+uuid.uuid4().hex.upper() if action=='speak' else None
            result={'round':b['round'],'completedTurn':b['turn'],'nextTurn':b['turn']+1,'speaker':snap['members'][(snap['members'].index(snap['speaker'])+1)%len(snap['members'])],'letterId':lid}
            if action=='skip':result.update(skipped=snap['speaker'],skippedBy=actor,reason=b['reason'],approval=b['approval'])
            self._record_operation(c,op,'round-trial',b,actor,'applied',result)
            at=approvals.now()
            if lid:
                recipient=result['speaker']
                c.execute('INSERT INTO letters VALUES (?,?,?,?,?,?,?)',(lid,'discussion',actor,recipient,snap['task'],op,at))
                tid=self._insert_text(c,lid,'request',b['body'],'',(snap['canonical']['doc'],snap['canonical']['section']),actor,op)
                self._record_request_doc(c,lid,tid,snap['canonical']['doc'],op)
                self._insert_event(c,lid,'sent',actor,actor,None,tid,'',True,op,at)
                prev=next((x['letter_id'] for x in reversed(snap['history']) if x['letter_id']),snap['anchor']['id'])
                if prev:
                    root=snap['threadId']
                    c.execute('INSERT INTO letter_links VALUES (?,?,?,?,?)',(lid,prev,root,op,at))
            c.execute('INSERT INTO trial_turns VALUES (?,?,?,?,?,?)',(b['round'],b['turn'],actor,action,lid,at))
            c.execute('INSERT INTO trial_next VALUES (?,?,?)',(b['round'],b['turn']+1,result['speaker']))
            final=self.advance_skipped(c,b['round'])
            return result
