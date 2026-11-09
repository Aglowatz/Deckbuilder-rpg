#!/usr/bin/env bash
# Overnight Nov 8-9: runs the static quest audit and writes docs/quests/quest_audit.md (errors fail the run).
cd "$(dirname "$0")/.." || exit 1
QUEST_AUDIT_WRITE=1 bash tools/run_tests.sh --only=tests/core/quests/test_quest_audit.gd
