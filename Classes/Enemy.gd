extends KinematicBody

class_name Enemy

#Settings to override
var health = 10
var walk = 1
var run = 5
var circleToLunge = true	#Does circling close or maintain dist?
var circleDist = 3			#Dist to circle at
var maxCircleDist = 5		#Maximum distance while circling
var proximity = 1			#Dist to trigger charged

#location storage, we determine state with these
var alertLoc = null			#Loc of most recent alert
var spottedLoc = null		#Loc of spotted
var randomLoc = null		#for meandering, fleeing, etc

#state info used for actions
var wasCharged = false		#Charged flag
var isAlive = true
var speed = 0
var targetLoc = null
var flankRight = true

#current functions
var idle = funcref(self,'meander')
var alerted = funcref(self,'pursue')
var spotted = funcref(self,'charge')
var charged = funcref(self,'withdraw')

var nav
var path = []
var path_idx = 0

#Alerts, spots, and being attacked forces state options

func _process(delta):
	if(!isAlive):
		return
	if isSpotted():
		if isCharged(spottedLoc):
			charged.call_funcv([delta])
			return
		spotted.call_funcv([delta])
		return
	if isAlerted():
		if(path == null):
			path_idx = 0
			path = nav.get_simple_path(translation, alertLoc)
		alerted.call_funcv([delta])
		return
	if isIdle():
		idle.call_funcv([delta])
		return

func _physics_process(delta):
	if(!isAlive):
		return
	var space_state = get_world().direct_space_state
	look(space_state)
	if(targetLoc != null):
		turnTowards(targetLoc,PI/2 * delta)
		if(targetLoc.distance_to(translation) > 1):
			move_and_collide(transform.basis.x * speed * delta)

#must be invoked by physics thread
#Adds the nearest ETarget that enemy has a 180 degree line of sight on
func look(space_state):
	var closest = 99999
	var current = null
	var tempDist
	for dude in get_tree().get_nodes_in_group("ETargets"):
		var ray = space_state.intersect_ray(translation,dude.translation,[self])
		if(ray.collider_id == dude.get_instance_id()):
			tempDist = translation.distance_to(dude.translation)
			if(Vector3(1,0,0).dot(to_local(dude.translation)) > 0):
				if(tempDist < closest):
					current = dude
					closest = tempDist
	if(current != null):
		spottedLoc = current.translation
		alertLoc = spottedLoc
		path = null
	else:
		spottedLoc = null

func pulse():
	pass

#STATE CHECKS

func isIdle():
	return (alertLoc == null && spottedLoc == null)

func isAlerted():
	return (alertLoc != null)

func isSpotted():
	return (spottedLoc != null)

func isCharged(loc):
	return translation.distance_to(loc) < proximity

#BASIC OPS

func hit(dam):
	health -= dam
	if(health <= 0):
		death()

func death():
	isAlive = false
	rotation.x = PI/2

#IDLE

func wait():
	speed = 0

func meander(_delta):
	speed = walk
	targetLoc = randomLoc

func patrol(_delta):
	pass

#ALERTED

func pursue(_delta):
	if(path_idx < path.size()-1):
		if(translation.distance_to(path[path_idx]) < 5):
			path_idx += 1
		speed = run
	else:
		speed = walk
	targetLoc = path[path_idx]

func approach(_delta):
	speed = walk
	targetLoc = alertLoc

func flee(_delta):
	pass

#SPOTTED

func charge(_delta):
	speed = run
	targetLoc = spottedLoc

func maintain(_delta):
	speed = 0
	targetLoc = spottedLoc

func circle(_delta):
	flankRight = randi()%2==1
	if(circleToLunge):
		speed = run
	else:
		speed = walk

#PROXIMITY / CHARGED

func lunge(_delta):
	pass

func withdraw(_delta):
	pass

#UTILITIES

func turnTowards(targetVec, delta):
	var final = (targetVec - translation)
	var temp = turnby(rotation.y, atan2(-final.z,final.x), PI * delta) - rotation.y
	rotate_y(temp)

func turnby(from, to, weight):
	var short = short_angle_dist(from, to)
	if abs(short) > weight:
		return from + (weight * sign(short))
	else:
		return from + short

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
