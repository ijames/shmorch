#!/usr/bin/env bash
# duration.sh — Report durations from state/timelog.md
# Usage:
#   bash tools/duration.sh            full summary grouped by day
#   bash tools/duration.sh last       time since last event
#   bash tools/duration.sh today      today's events with gaps

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
LOG="state/timelog.md"
[ -f "$LOG" ] || { echo "No timelog found."; exit 0; }

MODE="${1:-summary}"
LOG_CONTENT="$(cat "$LOG")"

python3 - "$MODE" "$LOG_CONTENT" << 'PYEOF'
import sys, re
from datetime import datetime
from itertools import groupby

mode = sys.argv[1]
log = sys.argv[2]
pattern = re.compile(r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\] ([^\|]+)\| (.+)')
entries = [(datetime.strptime(m.group(1), '%Y-%m-%d %H:%M:%S'),
            m.group(2).strip(), m.group(3).strip())
           for m in pattern.finditer(log)]

if not entries:
    print("No timelog entries yet."); sys.exit(0)

def fmt(secs):
    s = int(secs)
    if s < 60:   return f"{s}s"
    if s < 3600: return f"{s//60}m {s%60}s"
    return f"{s//3600}h {(s%3600)//60}m"

now = datetime.now()

if mode == 'last':
    ts, event, detail = entries[-1]
    print(f"Last:  [{ts}] {event} | {detail}")
    print(f"Since: {fmt((now - ts).total_seconds())} ago")

elif mode == 'today':
    today = now.date()
    items = [(ts,e,d) for ts,e,d in entries if ts.date() == today]
    if not items: print("No events today."); sys.exit(0)
    print(f"\nToday ({today}) — {len(items)} events:\n")
    prev = None
    for ts, event, detail in items:
        gap = f"+{fmt((ts-prev).total_seconds())}" if prev else "start"
        print(f"  [{ts.strftime('%H:%M:%S')}]  {gap:>10}  {event} | {detail}")
        prev = ts
    span = (items[-1][0] - items[0][0]).total_seconds()
    since = (now - items[-1][0]).total_seconds()
    print(f"\n  Span: {fmt(span)}   ({fmt(since)} since last event)")

else:  # summary
    print(f"\nTimelog — {len(entries)} events total\n")
    for date, grp in groupby(entries, key=lambda x: x[0].date()):
        day = list(grp)
        span = (day[-1][0] - day[0][0]).total_seconds()
        print(f"  {date}  ({len(day)} events, {fmt(span)} span)")
        prev = None
        for ts, event, detail in day:
            gap = f"+{fmt((ts-prev).total_seconds())}" if prev else "  start"
            print(f"    [{ts.strftime('%H:%M')}]  {gap:>9}  {event} | {detail}")
            prev = ts
        print()
PYEOF
