# pi-kognog-azerothcore — the list

**Updated after every step.** This is the handoff between sessions: what is next, what is
waiting, what was just done. Every fix or feature also gets a GitHub issue, opened with a full
explanation and closed with one.

The guide itself (Chapters 00–10) is complete and was proven by wiping the Pi and rebuilding it
from the text. What is left is optional chapters, modules and upkeep.

---

## Next up

- [ ] **Server Batch B: `mod-ah-bot-plus`** (NathanHandley). Check the fork carries AzerothCore
      commit `3f46e05` or later first; it needs a regular (non-bot) character as the auction-house
      character; only ever one auction-house module
- [ ] **Bot population experiment** (40 / ~200 / 500 bots, and how combat feels at each) → a
      "choosing your world's population" note in the guide
- [ ] **Optional chapter: Remote Play — Sharing the Realm** (Tailscale node sharing, client
      `realmlist`, one game account per player). Validated in a VM before it is written, like the
      rest of the guide. Two remote players are waiting on their side (Tailscale account, client)

## Waiting on Balih

- [ ] The two remote players: share the Pi from the Tailscale admin console, then their PCs and
      game accounts

## Ideas, not scheduled

- [ ] The realm's backups joining the HomeLab restic chain (off-box copy)
- [ ] The client's Hyprland window rule: one general rule for Wine games, instead of a per-machine
      rule (belongs to hypeForge, finding F-40)

## Done — most recent first

- [x] **2026-10-02 · `CLAUDE.md`**: the project rules for the AI co-author (names, the "only what was run" rule, who runs what on the Pi, writing and publishing), public on purpose
- [x] **#3 · 2026-10-01 · On Hyprland the camera spun by itself and menus stopped taking clicks.**
      `play-wotlk.sh` now uses Wine's own Wayland driver on Hyprland only; borderless window plus
      a full-screen window rule. Chapter 08 and a Troubleshooting entry. Played properly, from the
      terminal and from the desktop icon
- [x] **#2 · 2026-10-01 · Password reset without the console.** `scripts/reset-password.sh`
      writes a new SRP6 salt + verifier (same math as AzerothCore's own `account set password`),
      checks it against the database, and keeps the realm running. Used for real on the realm the
      same day; Troubleshooting entry rewritten
- [x] **#1 · 2026-08-31 · The realm stayed down after a MySQL restart.** A drop-in on
      `mysql.service` brings both realm services back (Chapter 10, Step 5)
