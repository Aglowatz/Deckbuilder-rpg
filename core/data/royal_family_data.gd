class_name RoyalFamilyData
extends Resource
## The royal family, the rescuer and the place names that may still change, each in ONE place (`data/story/royal_family.tres`,
## next to the villain in `villain.tres`). Story text uses the tokens listed in `RoyalFamily`; `Villain.fill` swaps them in
## when text is read, so renaming anything later is a one-line edit of the .tres.

@export var prince_name: String = "Tessar"
@export var prince_full_name: String = "Prince Tessar Wayweaver"
@export var royal_house: String = "Wayweaver"
@export var king_name: String = "King Harmon Wayweaver"
@export var queen_name: String = "Queen Concordia Wayweaver"
## The defected Path-ologist who smuggled the prince out (name undecided; see docs/design/open_questions.md "Story v2").
@export var rescuer_name: String = "The Rescuer"
@export var kingdom: String = "Pathavia"
@export var town: String = "Crosspath"
## The Capital before and after Primm falls.
@export var capital: String = "Primm's Perfection"
@export var capital_liberated: String = "Pathordia"
@export var showcase: String = "the Showcase Quarter"
