class_name VillainData
extends Resource
## The big bad's name and the title he insists on, in ONE place (`data/story/villain.tres`). Story text uses the
## tokens `{villain}` (the name) and `{villain_title}` (the title); `Villain.fill` swaps them in when text is
## read, so renaming him later is a one-line edit of the .tres.

@export var villain_name: String = "Primm"
@export var villain_title: String = "His Perfection"
