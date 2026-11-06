## Starting a fresh game (do this at the start of every Path)

The title screen shows Continue / Load Game because this PC has the developer's saves; a brand-new player would see only New Game.
Look at the title screen, then start a fresh game with the driver's own command (it never touches a save slot):

```
wait 2
shot 01_title
dev newgame
wait 6
```

Never use the title's New Game / slot screen (every slot holds the developer's saves).

You wake in a forest; the wake-up lines lead into a conversation and then a **Path choice** screen with four columns:
Beefcake (click about `415 400`), Gourmand (`670 400`), Refusemancer (`930 400`), Necrocrat (`1185 400`); `button More` opens a longer
description, `button Begin` confirms. After that you are in the forest with the Deck button top right. The cave (the tutorial dungeon) is
through the ruined arch to the north-east of the bedroll; walk with `hold`, interact with `key E` when a prompt appears (look at the
screenshots to see prompts), or use `dev travel dungeon D-TUT` if you cannot find the way (note that in your report). Dungeons are
node maps: click a node to move there, fights start when you reach an enemy node.

