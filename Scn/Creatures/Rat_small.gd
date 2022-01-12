extends Enemy

var sniff_loc = null

func _ready():
	nav = get_node("../Navigation")
	pulse()
	pass # Replace with function body.

func pulse():
	if(!isAlive):
		return
	randomLoc = to_global(Vector3(10-randi()%20,0,10-randi()%20))
	$Timer.start(3+(randi()%5))
	if(isAlerted() && sniff_path.size()==0):
		sniff_loc = spottedChar.translation
		sniff_path_idx = 0
	if (isAlerted() && sniff_path.size() > 0 && sniff_path_idx == sniff_path.size()):
		alertLoc = null

func hasLostSight(space_state):
	if(path == null):
		alerted = funcref(self,'pursue')
		sniff_loc = null
		sniff_path = []
		sniff_path_idx = 0

func reachedEndOfAlertedPath(_delta):
	if(sniff_loc != null):
		sniff_path = nav.get_simple_path(translation,sniff_loc)
		alerted = funcref(self,'sniff')
	else:
		alertLoc = null

func _on_Timer_timeout():
	pulse()
