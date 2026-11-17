# Critic 3 - story and writing (Nov 17)

## 1. How I played

- I read all of `story_script.md` (939 lines) in order before playing.
- I used all 6 runs, each 170 s or shorter, one at a time, in the foreground.
  - **Runs 1-3:** New Game. I read the forest prologue up to the Path picker (shots `n17story_01_*`, `n17story_02_*`, `n17story_03_*`). In run 3 my picker click landed while dialogue was still on screen, so I never got past the picker. `dev save` during the prologue says "Nothing to save yet", so every opening run had to replay it from the title.
  - **Runs 4-6:** `dev load bot_refusemancer_town_after_refusemancer`, then I tried to walk to Elder Maren. I never reached her:
    - Run 4: four seconds of sprinting moved me about 20 map pixels (`n17story_04_map2`). Every E press hit Brindle the Baker.
    - Run 5: I ran straight into the square's fountain and stayed there (`n17story_05_map2`, `n17story_05_a`).
    - Run 6: I went right and then north, and came out at the forest edge (`n17story_06_a`).
  - So **I did not see a memory scene in game.** I judge the memories from the script only.
- **Ending:** `dev load c13end` loads, but not at "the moment before the last boss falls". It puts you in the Capital after the ending: the quest is "Under the Forest", and the toast says "At the end of Grave Row, the city is gathering at dusk." (`n17story_06_end0`). `pilot` reported "no battle on screen". **I could not see the ending cutscenes in game.** I judge them from the script.
- **Not reached in game:** the cave and Maren's cave-mouth scene, any memory, any cave-mouth scene with Elowen, Primm, the ending, the funeral.

## 2. Score: 6/10 (story and writing)

- **Clarity 5/10.** The spine is easy to follow: amnesiac prince, four freed zones, four memories, a tyrant who means well. The details around it don't hold together. Primm both does and does not know who the hero is. The D.N.A. "Tuesday" payoff contradicts itself. Two separate mechanisms explain "nothing dies".
- **Fun 7/10.** The jokes are the best thing here: Brick's capital-letter spotter, Quota's stopwatch, Plume's loudspeaker ("Please report anyone who exists"), Agnes's "One more week, Hob". The writing has a voice that Sea of Stars fans will warm to. The best of it is the side cast, not the leads.
- **Polish 6/10.** Sentences are clean and well punctuated, and the presentation is strong (`n17story_01_a`, `n17story_01_k`). There is a lot of repetition, though: the "best student I ever had" line comes from three mentors, Hob's "What are you writing?" exchange runs six times, and Flex says "not the part that matters" three times in a row. And the finale's big speech is stitched together from other characters' lines.

## The arc in five sentences

1. A nameless young man wakes in a forest, gets pulled out of a hunt by a hooded friend, and is taken in by Elder Maren, a half-blind tortoise who bakes pie in Crosspath.
2. Primm, the Minister of Improvements, has put each of the four Paths (Beefcake, Gourmand, Necrocrat, Refusemancer) under a ruler. The Wanderer frees them one at a time, and each zone's story is about letting go: of iron, of a face, of a rule, of grief.
3. After each freed zone a memory comes back: a lullaby, a cell with bars on every side, a coup in the throne room, and finally his name, Prince Tessar Wayweaver. Maren confesses that her research was used to build his cell.
4. In the Capital he beats Primm through three phases (sameness, mirror, unravelling). Primm turns out to be a frightened man who killed the king and queen "so nobody would ever be wrong". The kingdom reassembles as a crooked, arguing whole.
5. The ending holds a royal funeral where his parents' ghosts walk away with Death (Old Hob). Elowen, the rescuer, is still locked in the Path-ology Lab, and that becomes the post-game hook.

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | **The central relationship never pays off.** Elowen rescues you and keeps promising "when it's over, I'll tell you all of it. My name first." Then a PR man tells you her name instead, she is captured, and the credits roll with her still in a cell ("Someone is still waiting there"). The player's warmest bond is used as a sequel hook. | Script: "cave mouth 4" step 4; "pc capture" steps 5-10; Ending, thanks line 1 | major | Give her the name beat. At the gate, before the guards reach her, she says "Elowen. It's Elowen. I promised." Then Plume names her surname. Put the Lab rescue before the credits, or at least add a short scene with her at the Pathwork Throne. |
| 2 | **The finale argument is a collage of other people's lines, and the hero has no voice of his own.** Against Primm he recites Flex ("strength is not control", "not the part that matters"), the Grand Chef ("a name is a blank page") and Agnes ("No order... outranks treating people with respect"). Before that he is mostly a question-asker ("Who are you?", and "What are you writing?" six times). | Script: "primm p1" beat 2, "primm p2" beat 2, "primm p1 2 rushed" | major | Keep one quoted lesson per phase at most. Write each answer from his own ten years: "They said 'again' every morning. I learned to hear a different word in it every day." Add two or three lines of the Wanderer's own opinions to the zone scenes. |
| 3 | **Primm does and does not know who you are.** Plume calls you "laboratory property" at the gate. Primm then greets you as an unknown visitor ("I so rarely receive anyone who has not been summoned"), hints "you, of all people", reveals "you have been so very hard to find" to someone who just walked in, and then says "you, I looked after". | Script: "pc capture" step 5; "primm intro" beat 1; "primm p1" beat 3; "primm reveal" beat 3; "primm end" beat 4 | major | Have him know from the first line (see line fix 1), and change "so very hard to find" to "so very careless to lose". |
| 4 | **The D.N.A. payoff undoes itself.** The note says the transfer was "FILED ON A TUESDAY". Mortimer says Tuesday "is not a business day", which should void it. Then he says "The authorization was valid, and it was always valid." The joke's logic collapses, and the reason the office is "now vacant" is unclear. | Script: D.N.A. / Hall of Final Approvals, "ha boss" after the node | major | Make the Tuesday void it: "So it was never valid. Not for a single day. ...And I obeyed it for ten years." The vacancy then follows from that. |
| 5 | **The world after the ending contradicts the ending text.** The ending says shopfronts topple, hedges slump back into shape, and "Behind the facade are houses, lawns and people". The c13end save shows the Gate Road still blighted: cracked ground, dead trees, purple thorns, and regime banners still on the castle. | `n17story_06_end0`; script: Ending, beat 2 | major | After the ending, switch the Gate Road to the freed look (grass, banners down or replaced with the four-sign ring), or cut the ending lines that promise it. |
| 6 | **Key reveals repeat.** "The best student I ever had" is said by Flex about Clench, by Maren about Elowen's father (twice), and Clench says it about himself. Maren announces "I taught the royal children" in Memory 2, then again in Memory 3 as if it were new. Her big confession is weakened by the echo. | Script: "rescue" beat 3; Memory 2 after; Memory 3 after; "maren after capture" step 2 | minor | Keep "best student" for Flex only. Maren says "my brightest apprentice". Memory 3 opens with "Teaching wasn't all I did at that castle" (line fix 7). |
| 7 | **Death's running gag and the logic of death both blur.** Hob's "What are you writing?" / "Appointments... not for a good long while" runs almost word for word six times. "Nothing dies" is explained twice: nobody has been collected anywhere because of D.N.A. paperwork, and also nothing dies in the Dump because of the seed. | Script: "hob town first", "hob town", "hob beefcake", "hob gourmand", "hob necrocrat", "hob town after funeral"; "hob refusemancer" step 1 | minor | Keep the exchange three times (first meeting, D.N.A., after the funeral) and vary it. In the Dump, Hob says "Even I couldn't take a leaf here, and that's not paperwork, that's something worse." |
| 8 | **Who gave the seed, and what it was, keeps shifting.** Compostella calls it Primm's gift. Clipwell says she brought it herself because the Archdruid was crying. Afterwards Compostella says "It was my own grief all along, dressed up as a seed." | Script: "sever" beat 1; "clipwell mill" step 5; "clipwell lawn" step 4; Archdruid after-freeing | minor | Pick one: "Primm's groundskeeper brought it, and my grief planted it" (line fix 6). Cut "dressed up as a seed". |
| 9 | **The Escoffina naming confuses.** The Doppelganger says "Your name was the only one I had". The Grand Chef gives away "my old name: Escoffina... prouder of the work than of the title". A name is not a title, and the Grand Chef is never named again. The finale also leans on this scene ("I watched a cook give her own name away"). | Script: "wonder" beats 2 and 6 | minor | Line fixes 4 and 5: she gives away her given name, which she never uses. |
| 10 | **Reaching the story is hard.** In two runs I could not walk from the square to Maren's door to trigger a memory. The fountain blocks the straight road on the map (`n17story_05_a`), and going round it took me into the treeline (`n17story_06_a`). The four memories are the spine of the story, so a blocked route to them hurts the story. | `n17story_04_map2`, `n17story_05_map2`, `n17story_05_a`, `n17story_06_a` | minor | When a memory is ready, show a "Visit Elder Maren" prompt that fades to her kitchen. Or put a clear walkable lane round the fountain that the dotted route follows. |

**Two more things I could not check in game:**
- The exported script orders the ending as: beats 1-7, credits, thanks, return, then Primm's reveal and beats 8-10 (Pathwork Throne, "{villain} Sees", Maren's "Welcome home"). If the game plays them in that order, the emotional climax comes after "THE END". c13end did not let me check.
- The script labels the gravedigger "Old Hob the Gravedigger (secretly Death)", and attributes Ending beat 10 (Maren's homecoming) to "Agnes Overdue". If either label reaches the in-game nameplate, it spoils the funeral or confuses the scene. Check both.

## Lines to fix

| # | Speaker, section | Line | What is wrong | Replacement |
|---|---|---|---|---|
| 1 | Primm, "primm intro" beat 1 | "Ah, a visitor. Do come in. I so rarely receive anyone who has not been summoned." | Plume has just called you lab property, and Primm later says he looked after you. Pretending not to know you reads as a contradiction, not a bluff. | "Ah. My missing item, come home on its own. Do come in." |
| 2 | Mortimer, "ha boss" after the node | "The authorization was valid, and it was always valid. But the office is now vacant, and policy is policy." | Contradicts the Tuesday joke two lines earlier. | "So it was never valid. Ten years of no, filed on a Tuesday." |
| 3 | Percival Plume, "pc plume memo" step 5 | "Why, beneath the forest where you... oh. Oh, I really shouldn't have said that, should I?" | The memo the player just read already says "beneath the forest", so the slip reveals nothing. | "Why, to her father, the Director! Oh. I really shouldn't have said that." |
| 4 | The Grand Chef, "wonder" beat 6 | "Take my old name: Escoffina. I was always prouder of the work than of the title, and that name could do with somebody making a fresh start in it." | Mixes up name and title, and leaves the Chef nameless. | "Take my given name, Escoffina. Everyone calls me Chef; it's wasted on me." |
| 5 | The Doppelganger, "wonder" beat 2 | "Your name was the only one I had, and now it is yours again." | It wore her title and face, not her name. | "Your title was the only name I had, and now it is yours again." |
| 6 | Archdruid Compostella, "sever" beat 1 | "It's the seed, {villain}'s gift: life that never dies." | Clipwell says she gave it, out of pity. | "It's the seed his groundskeeper brought me: life that never dies." |
| 7 | Elder Maren, Memory 3 after | "I knew that throne room, dearie. I worked at the castle once, studying the Paths, and of an afternoon I taught the royal children their letters." | Repeats what she said in Memory 2 as if it were new. | "I knew that throne room, dearie. Teaching wasn't all I did at that castle." |
| 8 | Elder Maren, Memory 3 after | "That's my secret, and now you're holding it, the same way I have been holding yours." | She doesn't know his secret until Memory 4. | "That's my secret, and now you're holding it. Do with it as you see fit." |
| 9 | Primm, "primm p2" beat 3 | "That is simply not true. I made the wells, and I made the roads." | Doesn't answer "You don't get to decide who I am". | "Decide who you are? I decided who everyone was. I made the wells, the roads." |
| 10 | Hollow Warden, boss intro opening line | "Then I will do what I was left here to do." | "Then" answers nothing; it is the first thing he says. | "Nobody leaves this cave. I was left here to see to that." |
| 11 | Prudence Pallor, D.N.A. gatekeeper before the battle | "The authorization is valid, and policy states that I must stop you." | First mention of "the authorization", with no explanation. | "The transfer of authority is valid, and policy says I must stop you." |
| 12 | Mortimer Grimsby, after freeing | "You held 4,000,213, and you did not wait for it to be called." | Prudence said "Your number is zero, as is everyone's." | "Your number was zero, and you did not wait for it to be called." |
| 13 | The Wanderer, "cave mouth 3" step 3 | "Everywhere I go, someone tells me a story about a little prince, and then they look at me and stop talking." | No such scene appears anywhere in the main story. It claims a setup the game never shows. | "Maren keeps starting a story about a boy at court, then stops. You knew me, didn't you?" |
| 14 | Gatekeeper Brannoch, "capital offer" | "So now it's Blackout, Famine, Restless Dead and Clutter up there. Dark streets, slow legs, no food that heals, rubbish in your deck." | A rules tooltip spoken in his voice. "Restless Dead = slow legs" is unclear. | "Dark up there now. Hungry. The dead won't lie still, and the bins are everywhere." |
| 15 | The Rescuer, prologue "rescuer 1" | "Easy, now. Stay down for a moment and get your breath back." | On screen the hero is already standing (`n17story_01_h`). | "Easy, now. Slowly. Get your breath back before you try to walk." |

## Characters

**Best written:**
1. **Elder Maren.** Her failing eyes are set up from her first line ("my eyes, which see as far as a pie and not much further") and pay off in the fourth memory: "I told him, 'So that we are never far from home.'"
2. **Primm.** A villain who is pitiable without being excused: "Take the crown. No: leave it. No: take it." and "Tell the Wrinkles... tell them I am sorry about the hats. (He hears himself.) No. That is not the thing."
3. **Gatekeeper Brannoch.** Six words of setup and the best homecoming in the game: "Wrote you in the book. Every day. 'Isla. Not yet.' Today it says 'home'." Agnes Overdue is a close fourth.

**Weakest:**
1. **The Wanderer.** He reacts and quotes others; his own lines are mostly questions: "I'm sorry to be a trouble." and "What are you writing?" (six times).
2. **The Doppelganger / Escoffina.** It has a striking reveal ("there is nothing in here to taste with"), but the naming muddle (problem 9) makes its redemption hard to follow.
3. **Hortensia Clipwell.** Her motive flips from tidy zealot ("All that rot... being honest with everybody. So untidy.") to soft-hearted giver ("I gave her the seed because she was crying"), and the game never connects the two.

## 4. Three things that work and must not be lost

1. **The stills with narration.** The painted wake-up still with the text panel is a confident, Octopath-grade opening (`n17story_01_a`, `n17story_01_c`).
2. **Two-portrait dialogue framing.** Speaker nameplate, both portraits and readable text, with the 3D scene still visible between them (`n17story_01_k`, `n17story_01_h`).
3. **The Grave Row funeral as the real ending.** It is set up by Hob's "Two particular graves I've been at, these ten years" and the Memory 1 lullaby, and paid off with "She hums the first bars of the lullaby, and does not need to finish it." The game signposts it after the ending: "At the end of Grave Row, the city is gathering at dusk." (`n17story_06_end0`).

## 5. SCRIPT ERROR lines

None. `play_n17story_01.log` to `play_n17story_06.log` (and the `_play` logs) each contain 0 `SCRIPT ERROR` lines.
