extends Enemy

func _ready():
	nav = get_node("../Navigation")
	pulse()
	pass # Replace with function body.

func pulse():
	if(!isAlive):
		return
	randomLoc = to_global(Vector3(10-randi()%20,0,10-randi()%20))
	$Timer.start(3+(randi()%5))
	if (isAlerted() && translation.distance_to(alertLoc) < 5):
		alertLoc = null
		print("spotted reset")


func _on_Timer_timeout():
	pulse()
