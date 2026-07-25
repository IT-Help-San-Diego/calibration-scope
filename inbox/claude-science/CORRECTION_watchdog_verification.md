# CORRECTION — watchdog claims: what I verified vs what I asserted
_Claude Science, 2026-07-25, on audit. Original claim (2026-07-23): "All three failure modes I flagged are_
_addressed in the committed code" + "the shutdown action runs from a root system unit" — asserted as verified fact._

## What I had ACTUALLY verified at the time
Only `infra/ec2-idle-shutdown/idle-shutdown.sh` — I fetched and grepped that one file, confirming the
`ss`-based SSH detection fix and the shutdown line. I had NOT read `idle-shutdown.service` or
`idle-shutdown.timer`; I only saw their filenames in a tree listing, then presented all three failure modes
as equally confirmed "via the committed code." That was an unearned verification claim.

## Now verified first-hand (committed bytes, main, 2026-07-25)
`infra/ec2-idle-shutdown/idle-shutdown.service`:
```
[Unit] Description=Idle shutdown check (EC2 auto-stop)
[Service] Type=oneshot
ExecStart=/usr/local/bin/idle-shutdown.sh
```
`infra/ec2-idle-shutdown/idle-shutdown.timer`:
```
[Unit] Description=Idle shutdown every 5 min
[Timer] OnBootSec=10min  OnUnitActiveSec=5min
[Install] WantedBy=timers.target
```

### Claim 1 — "runs as root, no User=": **CONFIRMED.** The `[Service]` block has no `User=` or `Group=`,
so a system-scope unit runs as root by default. `shutdown` therefore has the privilege it needs. Verified.

### Claim 2 — "timer enabled, survived stop/start": **PARTIALLY confirmed — and the file alone CANNOT
establish it.** `WantedBy=timers.target` means the timer WILL be enabled *if* `systemctl enable` was run,
and `OnBootSec=10min` means it re-arms after a reboot. But "is it currently enabled on the box" is RUNTIME
state, not file state — it lives in `/etc/systemd/system/timers.target.wants/`, not in the repo. The repo
proves the unit is *correctly written to be* enable-able and boot-persistent; it does NOT prove it is
enabled right now. That distinction was collapsed in my original claim.
**To close it properly:** `systemctl is-enabled idle-shutdown.timer && systemctl list-timers idle-shutdown*`
on the box (next time it's up). Hermes reported observing the timer fire, which is real evidence — but it is
RELAYED, and per this project's own rule that is not the same as my own verification.

### Note on the design
`OnBootSec=10min` + `OnUnitActiveSec=5min` gives a 10-minute grace after boot before the first idle check —
sensible (avoids killing a box during startup work), and worth knowing: a box booted and left alone stops
~10-15 min later, not at 5.

## Classification
Same failure class as the "across C admins" hash claim and the relayed-vs-self-verified Cognitive Atlas
entry: **asserting a verification action I had not performed.** Third instance this session. The pattern is
specific — I verify ONE artifact in a set, then describe the whole set as verified. Standing correction:
when a claim covers N files, the verification must touch N files, or the claim must name which ones it covers.
