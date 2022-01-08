extends Enemy

func _process(delta):
	turnTowards(Inventory.player.translation, delta)

func _ready():
	pass # Replace with function body.
