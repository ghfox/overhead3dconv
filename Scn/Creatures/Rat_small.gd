extends Enemy

var sniff_loc = null
var anims


func _ready():
	anims =$AnimationPlayer
	idle = funcref(self,'meander')
	alerted = funcref(self,'pursue')
	spotted = funcref(self,'charge')
	charged = funcref(self,'lunge')
	health = 4
	walk = 3
	run = 14
	proximity = 6
	nav = get_node("../../Navigation")
	pulse()
	anims.play("Idle")
	pass # Replace with function body.

func _process(delta):
	._process(delta)
	if(!isAlive):
		return
	if(!canAttack):
		return
	if(speed == walk):
		if(anims.current_animation != "Walk"):
			anims.play("Walk")
	if(speed > walk):
		if(anims.current_animation != "Run"):
			anims.play("Run")
	#this will need to change when attacks are added but works for now
	if(speed == 0):
		anims.play("Idle")

func pulse():
	if(!isAlive):
		return
	$Pulse.start(3+(randi()%5))
	randomLoc = to_global(Vector3(10-randi()%20,0,10-randi()%20))
	charged = funcref(self,'lunge')
	blockSpotted = false
	if(isAlerted() && sniff_path.size()==0):
		sniff_loc = spottedChar.translation
		sniff_path_idx = 0
	if (isAlerted() && sniff_path.size() > 0 && sniff_path_idx == sniff_path.size()):
		alertLoc = null

func hasLostSight(space_state):
	blockSpotted = false
	charged = funcref(self,'lunge')
	if(path == null):
		alerted = funcref(self,'pursue')
		sniff_loc = null
		sniff_path = []
		sniff_path_idx = 0

func reachedEndOfAlertedPath(_delta):
	speed = 0
	if(sniff_loc != null):
		sniff_path = nav.get_simple_path(translation,sniff_loc)
		alerted = funcref(self,'sniff')
	else:
		alertLoc = null

func _on_Timer_timeout():
	pulse()

func death():
	if(!isAlive):
		return
	anims.play("Death")
	isAlive = false
	$CollisionRat.disabled = true

func lunge(_delta):
	if(!.lunge(_delta)):
		return
	anims.play("Attack")
	$Shottimer.start(3.0)

func _on_Shottimer_timeout():
	canAttack = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "Attack"  && isAlive):
		if(isSpotted()):
			if(isCharged(spottedLoc)):
				charged = funcref(self,'withdraw')
				blockSpotted = true
				$Pulse.start(0.5 + randf())
