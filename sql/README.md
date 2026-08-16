# Custom SQL — realm-flavour changes

**This folder is optional, and it is not part of the build.** Chapters 00–10 give
you a working Playerbots realm; nothing in here is needed for that. What lives
here are deliberate changes *we* made to our own realm after it worked — kept in
the repo so they are documented, reversible, and easy to find again.

Read the header of any file before running it. Every script in here explains what
it does, why we did it, and how to undo it.

> **A rule that applies to everything in this folder:** re-apply after any
> AzerothCore **world-database** update. Upstream SQL rewrites loot templates and
> other tables, and it will quietly carry these values away with it. After every
> world-DB update, check whether the changes you rely on are still in place.

---

## Quest-item drop floor — 60%

| File | What it is |
|---|---|
| `custom/quest_drop_floor_60.sql` | The change. Raises every quest-required drop below 60% up to 60%. |
| `custom/rollback_quest_drop_floor_20260810.sql` | The undo. Restores every affected row to its original Blizzlike value. |

**The ruling behind it** (Balih, 2026-08-10):

> *"We want to go over quests. If things get tight because of experience, we just
> grind XP by fighting. But I want everyone to enjoy questing."*

On a solo realm with a bot party, a 12% quest drop is not a challenge — it is an
afternoon of killing the same boars while the fun waits. The floor puts a bottom
under that without touching anything that was already generous.

**What it actually does**

```sql
UPDATE acore_world.creature_loot_template
SET Chance = 60
WHERE QuestRequired = 1 AND GroupId = 0 AND Chance > 0 AND Chance < 60;
```

…and the same for `gameobject_loot_template`. Two things about that `WHERE`
clause are deliberate:

- **It only ever raises.** Anything already at or above 60% keeps its value, so
  re-running the script is harmless — it is safe to apply again after a world-DB
  update without thinking about it.
- **It skips group loot** (`GroupId = 0` only). Inside a loot group the chances
  are *relative to one another*, not absolute — raising one member shifts which
  item you get rather than how often you get one. Those rows are left alone on
  purpose.

**Scale on our realm:** roughly 1,660 of ~5,750 quest drop entries moved up
(1,643 creature rows + 25 gameobject rows). The rest already cleared the bar.

### Applying it

```bash
mysql -u <user> -p < custom/quest_drop_floor_60.sql
```

Then, in-game as GM — no restart, nobody gets disconnected:

```
.reload loot_templates_creature
.reload loot_templates_gameobject
```

Verify (expect `0`):

```sql
SELECT COUNT(*) FROM acore_world.creature_loot_template
  WHERE QuestRequired=1 AND GroupId=0 AND Chance>0 AND Chance<60;
```

### Rolling it back

```bash
mysql -u <user> -p < custom/rollback_quest_drop_floor_20260810.sql
```

…then the same two `.reload` commands.

> ⚠️ **The rollback is a point-in-time snapshot.** It holds the exact values that
> were in the database on 2026-08-10 — one `UPDATE` per affected row, not a
> formula. That makes it precise, but it also means it goes stale: if a world-DB
> update changes those tables and you apply the floor again on top, this file no
> longer describes what you overwrote. **Regenerate the rollback before every
> re-apply**, by capturing the current values of the rows the floor is about to
> touch. A stale rollback is worse than none, because it looks like a safety net.

---

## Should *you* run this?

Only if you want it. This is realm flavour, not a fix — a Blizzlike realm is
supposed to make you work for that drop, and plenty of people want exactly that.
We changed it because our realm is played by a small family group with limited
evenings, and the grind was eating the part we actually enjoy.

If you are following the guide to learn how the pieces fit together, skip this
folder entirely on your first build. It will still be here afterwards.
