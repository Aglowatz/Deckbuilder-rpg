# Reward cards (Brief 14, Part E)

Every reward card is a card of the designed set. Reward-only cards are flagged `not_in_packs` in `data/source/card_overrides.csv`
(they survive a re-import), so they never appear in packs, vendors or ordinary reward rolls.

| Source | Card(s) | Notes |
|--------|---------|-------|
| Quest: Necrocrat zone (`ZoneQuestDefinitions`) | N-14 | |
| Quests: Beefcake zone | B-17, B-12 | |
| Quests: Gourmand zone | G-25, G-07 | |
| Quest: Gourmand/Refusemancer | GR-04 | |
| Quests: Refusemancer zone | R-04, R-25 | |
| Capital Path quests (`CapitalContent.QUEST_REWARD_IDS`) | B-30, G-31, N-28, R-30 | one Signature-feeling card per Path; `not_in_packs` |
| Primm's Castle (`FINAL_REWARD_ID`) | P4-02 | the all-Path finale card; `not_in_packs` |
| Mini dungeons (`ZoneCards`) | N-29 (D.N.A.), B-28 (Gainlands), G-27 (Buffet), R-29 (Heap) | thematic unique, once per save |
| Main dungeons (`ZoneCards.MAIN_DUNGEON_REWARD_IDS`) | B-32 House of Gains, G-33 Test Kitchen, R-33 Rotheart, N-33 Hall of Approvals | the Path's Legendary |
| Zone vendors (`ZoneCards.*_VENDOR_IDS`) | 10 cards per Path (see the file) | commons/uncommons of the Path's identity |
| Black market (`CapitalContent.BLACK_MARKET_CARD_IDS`) | N-27, R-31, G-29, B-27, C-30, C-29, NR-12, GB-12 | |
| Scholar / toll keeper (`ContentDefinitions.reward_pool`) | C-20, C-21, C-22, C-15 | Colorless |
| Chests | drawn from the Path's reward table (`RewardGenerator`) | the old fixed chest cards were replaced by rolls |

Corrupted-NPC reference decks (`CorruptedNpcs.REFERENCE_EXTRA_PICKS`, balance simulation only) use basic cards of the Path.
