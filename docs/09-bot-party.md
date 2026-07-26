# Chapter 09 — Your bot party

The reason this whole project exists: a party that plays *with* you. This chapter summons a
five-man group you lead — tank, healer, two dps — and teaches you to command them. All of
it happens **in-game**, through the chat box, once you're logged in from Chapter 08.

> No SSH needed here. You control bots with chat commands: press **Enter**, type the
> command, **Enter** again.

## What this is

Playerbots gives you three kinds of bot, and the difference matters:

| Type | Summoned by | Behaviour | Best for |
|---|---|---|---|
| **Rndbots** | auto (ambient) + `addclass` | auto-quest, auto-loot, **auto-gear**, auto-talent | populating the world; quick test parties |
| **AddClass bots** | `.playerbots bot addclass <class>` | instant, come leveled/geared from the rnd pool | trying the party *right now*; testing |
| **Altbots** | `.playerbots bot add <name>` | your own characters; **do not** auto-gear | **long-term playthroughs** — you control their progression |

The fork itself calls `addclass` bots "for testing" and recommends **altbots** for a real
playthrough. Use `addclass` to feel the party click together tonight; build an altbot party
for the campaign.

> **The command prefix is `.playerbots`** — with an **s**. (`.playerbot`, singular, is the
> old fork's syntax and will only print a usage list here.)

## Why it matters

A solo player on a private realm still wants a group for dungeons and elite quests. This is
how you get one you actually command — and it's the load we sized the Pi for: one human + a
4-bot party.

## Before you start

- Chapter 08 complete: logged in as `BALIH` (a GM account — bot commands want GM rights),
  with a character in the world.
- Ambient random bots tuned down (Chapter 07) so the party isn't fighting the Pi for CPU.

## Steps

### 1. Instant party — `addclass` (quick, for testing)

In the chat box, one at a time. Run the tank first and watch it join before the rest:

```
.playerbots bot addclass warrior
.playerbots bot addclass priest
.playerbots bot addclass mage
.playerbots bot addclass rogue
```

That's the classic 5-man shape: **you + warrior (tank), priest (healer), mage + rogue
(dps)** — a full party of five, the max group size.

- They spawn near you, join your party, and **follow**.
- Class keywords are standard; the one exception is **Death Knight = `dk`**.
- These are rndbots: they **auto-loot and auto-equip** upgrades as you play. Handy, but the
  reason they're "testing only" — you don't control their gear.

If a command prints a USAGE list instead of summoning, you likely dropped the `s` in
`.playerbots` or the `bot` sub-word.

### 2. The command cheat-sheet (how to lead them)

Bots take orders in **party chat** (`/p`, whole group) or **whisper** (`/w BotName`, one
bot). The essentials:

| Command | What it does |
|---|---|
| `/p follow` | Regroup on you and follow. **The fix when they "stay behind" after a kill.** |
| `/p stay` | Hold position (park the healer safe; careful pulls). |
| `/p attack` | Focus-fire your current target on command. |
| `/w PriestName follow` | Same commands, aimed at a single bot by name. |
| `/p help` | Bots whisper back their own command list, in-game. |
| `.playerbots bot remove <name>` | Dismiss a bot (`remove *` dismisses all). |

Bots **auto-follow and auto-assist** by default — attack something and they pitch in, the
healer heals, the tank holds threat. `/p follow` is the one you'll use most: they hold
where combat ended and wait for their leader, so tell them to catch up.

**Strategies** (finer control, optional):

| Command | What it does |
|---|---|
| `/p co ?` | Show active **combat** strategies. |
| `/p co +loot` | Turn on the loot strategy (grab drops). |
| `/p co +/-<strategy>` | Enable / disable a combat strategy. |
| `/p nc +/-<strategy>` | Enable / disable a **non-combat** strategy. |

The full, authoritative list lives at the
[mod-playerbots Playerbot Commands wiki](https://github.com/mod-playerbots/mod-playerbots/wiki/Playerbot-Commands).

> **Field discovery — recruiting from the world.** You can also build a party from the
> random bots you *meet*: `/friend` a bot whose class you like, and later `/invite` it from
> your friends list — it comes to you (or appears) **as itself, with its real level and
> gear**, no summoning commands involved. Random bots accept invitations based on level by
> default (`AiPlayerbot.GroupInvitationPermission = 1` — set it to `2` in `playerbots.conf`
> to make them always accept). A very natural way to recruit companions you've actually
> adventured past.

### 3. The long-term party — altbots (recommended for a real campaign)

For a playthrough where the party is *yours* and progresses under your control, use your
own characters:

1. Create alt characters on the **same account** (`BALIH`) — one per party role.
2. Log them in as bots by name:
   ```
   .playerbots bot add Tankname,Healername,Dpsone,Dpstwo
   ```
   (Add a whole account's characters with `.playerbots bot addaccount <accountname>`.)

Altbots use the same command cheat-sheet in Step 2, but **won't** auto-gear or auto-talent
— you gear and spec them, and they level alongside you. That's the point: a party that's
genuinely part of *your* story, not disposable pool characters.

## ✅ Checkpoint

Chapter 09 is done when:

- `.playerbots bot addclass` summons bots that join your party and follow,
- they **fight when you engage** and **regroup on `/p follow`**, and
- you know how to dismiss them and toggle basic strategies.

You now have a party you lead. Next chapter keeps the realm alive: services, backups, and
moving the database onto the NVMe.

## ⚠ If it went wrong

- **Command prints a USAGE list, no bot appears** — the prefix is `.playerbots` (with `s`)
  and the sub-word is `bot`: `.playerbots bot addclass warrior`.
- **Bots stand still after a fight** — that's normal; they hold at the kill spot. `/p
  follow` brings them back.
- **"You are not allowed to use this command"** — your account isn't GM. Set it: on the Pi
  console, `account set gmlevel BALIH 3 -1` (Chapter 07).
- **Party won't grow past a point** — a group caps at 5 (you + 4). For more, you're into
  raid territory and higher bot counts, which a Pi will feel.
- **A kill-quest stops counting** — usually the quest is already complete (`L` shows `X/X`),
  or a bot is tagging mobs you're out of range for. Tag them yourself, or `/p stay` then
  pull. See Troubleshooting (Chapter 09).
