extends Enemy

func _ready():
	pulse()
	pass # Replace with function body.

func pulse():
	randomLoc = to_global(Vector3(10-randi()%20,0,10-randi()%20))
	$Timer.start(3+(randi()%5))


func _on_Timer_timeout():
	pulse()
