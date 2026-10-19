"""Fixed-color approval probe. No Git actions; run is explicitly performed by Astra."""
import argparse
import json
import approvals

COLORS = [('赤', '#bf2525'), ('橙', '#a34c00'), ('黄', '#806400'), ('緑', '#19713c'), ('青', '#245bc1'), ('藍', '#423396'), ('紫', '#86369b')]

class Store(approvals.Store):
    def __init__(self, database=approvals.APP / 'Approvals' / 'probe.sqlite3', root=approvals.ROOT):
        super().__init__(database, root)

    def _list(self, con):
        value = super()._list(con)
        value['policyNotice'] = '動作確認専用。承認後、Astraが拾うと色が進みます。コミット権限は与えません。自動起床はありません。'
        return value

    def seed(self):
        if any(x['status'] in ('pending', 'approved') for x in self.list()['requests']):
            raise approvals.Conflict('前の疎通ジョブが残っています')
        for number, (name, color) in enumerate(COLORS, 1):
            self.add(dict(taskId='OPS-115', title=f'疎通{number}：{name}', scope='固定色の文字表示だけ', paths=['Maintanance/RegistryApp/Approvals/probe.sqlite3'], condition='ユーザーの承認後にAstraが一度処理する', branch='疎通専用・Git操作なし'))
        return self.list()

    def run(self):
        with self.transaction() as con:
            rows = self._list(con)['requests']
            for item in rows:
                if item['status'] != 'approved':
                    continue
                _, card, state = self._row(con, item['id'])
                number = next(i for i, (name, _) in enumerate(COLORS, 1) if card['title'] == f'疎通{i}：{name}')
                state.update(status='consumed', consumedAt=approvals.now(), color=COLORS[number-1][1], result=f'疎通{number}：{COLORS[number-1][0]}', executor='Astra')
                self._save(con, item['id'], state, 'probe-result', {'result': state['result']})
                return {'processed': item['id'], 'result': state['result']}
            return {'processed': None}

    def claim(self, *args, **kwargs):
        raise approvals.Conflict('疎通ジョブはコミットに使用できません')

if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('action', choices=['seed', 'list', 'run'])
    print(json.dumps(getattr(Store(), p.parse_args().action)(), ensure_ascii=False, indent=2))
