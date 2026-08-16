-- ═══════════════════════════════════════════════════════════
--  Quest-item drop floor — 60%
--  Realm ruling (Balih, 2026-08-10): "We want to go over quests.
--  If things get tight because of experience, we just grind XP by
--  fighting. But I want everyone to enjoy questing."
-- ═══════════════════════════════════════════════════════════
--
--  Raises every quest-required drop BELOW 60% up to 60%. Nothing is
--  ever lowered — drops already above the floor keep their values.
--  Group-loot rows (GroupId > 0) are left alone on purpose: inside a
--  group the chances are relative to one another, so raising one
--  member shifts the balance instead of the odds.
--
--  Effect on this realm: roughly 1,660 of ~5,750 quest drop entries
--  move up; the rest were already generous enough to clear the bar.
--
--  RE-APPLY AFTER ANY AZEROTHCORE WORLD-DATABASE UPDATE. Upstream
--  SQL can rewrite loot templates and carry these values away with
--  it. The companion rollback file restores every original Blizzlike
--  value exactly.
--
--  Apply:   mysql -u <user> -p < quest_drop_floor_60.sql
--  Live:    .reload loot_templates_creature
--           .reload loot_templates_gameobject
--           (in-game as GM — no restart, nobody disconnected)
-- ═══════════════════════════════════════════════════════════

UPDATE acore_world.creature_loot_template
SET Chance = 60
WHERE QuestRequired = 1 AND GroupId = 0 AND Chance > 0 AND Chance < 60;

UPDATE acore_world.gameobject_loot_template
SET Chance = 60
WHERE QuestRequired = 1 AND GroupId = 0 AND Chance > 0 AND Chance < 60;

-- Verification (expect 0 rows remaining below the floor):
-- SELECT COUNT(*) FROM acore_world.creature_loot_template
--   WHERE QuestRequired=1 AND GroupId=0 AND Chance>0 AND Chance<60;
