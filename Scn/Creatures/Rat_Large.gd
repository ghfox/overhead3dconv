extends Enemy

var anims

func _ready():
	._ready()
	targets = get_tree().get_nodes_in_group("Player")
	friends = get_tree().get_nodes_in_group("Rats")
	anims =$AnimationPlayer
	idle = funcref(self,'meander')
	alerted = funcref(self,'pursue')
	spotted = funcref(self,'charge')
	charged = funcref(self,'lunge')
	health = 10.0
	walk = 3
	run = 14
	armor = 4.0
	proximity = 8
	seperation = 5
	nav = get_node("../../Navigation")
	pulse()
	anims.play("Idle")
	move_lock_y = true
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
	if(isAlerted() && sniffPath.size()==0 && lastSpotted != null):
		sniffLoc = lastSpotted.translation
		sniffPath_idx = 0
	if (isAlerted() && sniffPath.size() > 0 && sniffPath_idx == sniffPath.size()):
		alertLoc = null

func hasLostSight(space_state):
	blockSpotted = false
	charged = funcref(self,'lunge')
	if(alertPath == null):
		alerted = funcref(self,'pursue')
		clearSniff()

func reachedEndOfAlertedPath(_delta):
	speed = 0
	if(sniffLoc != null):
		sniffPath = nav.get_simple_path(translation,sniffLoc)
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
