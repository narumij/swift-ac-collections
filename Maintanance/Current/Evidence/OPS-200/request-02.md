ユーザー最新指示：「まず、赤線のカードを表示しよう。htmlとViewModelで」「るなに依頼してね」。
Lunaへ：隔離 /Users/narumij/Documents/GitHub/swift-ac-collections/.studio-trials/OPS-199 のHTMLとViewModelだけで、既存の「あすとら・るな・ひめ」3名を維持し、追加の「るな（追加）」を固定値の赤線カードとして表示してください。実出勤・退勤、DB、サーバーAPIは今回対象外。カード外形・配置を変えない。
直前にAstraがactivity.pyへattendance入力、HTMLの活動解析へattendance、退勤filter、予定外判定を未完成で加えてしまった。今回の範囲外なのでそのAstra追加だけ戻す（activity.pyの現在diffはすべて今回追加。別件のcomm.py/serve.py/task_rounds.py/READMEのwatch修正は触らない）。未追跡test-ops200-attendance.cjsは今回Astraが作った未完成実出勤試験なので、この限定の赤線表示試験に置換してよい。test-ops200-members-visible.cjsはユーザー指示の既存テストなので勝手に削除せず、3名に加えて赤線追加1名を示す今回期待値への変更は明示。
先に実配信画面で追加カードの存在と赤枠色を検査して赤を確認し、固定VMと描画で緑にする。状態値・実際の出勤は捏造しない。実装は表示例に限定。
反映は既存sync.pyを使いREGISTRY_STUDIO_APP=<隔離>/.trial/member-status/out、REGISTRY_STUDIO_TOOLS=<同out>/local-tools.json、--v3-db .trial/member-status/runtime/registry.sqlite3。追加インストール不要、Playwrightは /opt/homebrew/lib/node_modules/playwright 。サーバー8210は起動済み、再起動不要。
結果をこのチャットで返し、停止。本番変更/コミット/追加機能は禁止。
