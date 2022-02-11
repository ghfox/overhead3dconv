extends KinematicBody

class_name Enemy

#Settings to override
var health = 5.0
var armor = 1.0
var walk = 2
var run = 6
var circleToLunge = true	#Does circling close or maintain dist?
var circleDist = 3			#Dist to circle at
var maxCircleDist = 5		#Maximum distance while circling
var proximity = 3			#Dist to trigger charged

#Groups and things, must be set in child
var targets = []
var friends = []

#flocking
var seperation = 3

#location storage, we determine state with these
var alertLoc = null			#Loc of most recent alert
var spottedLoc = null		#Loc of spotted
var randomLoc = null		#for meandering, fleeing, etc

#state info used for actions
var spottedChar = null		#presently visible
var lastSpotted = null		#last/present spotted
var wasCharged = false		#Charged flag
var isAlive = true
var speed = 0
var targetLoc = null
var flankRight = true
var canAttack = true
var blockSpotted = false

#current functions
var idle = funcref(self,'meander')
var alerted = funcref(self,'pursue')
var spotted = funcref(self,'charge')
var charged = funcref(self,'withdraw')

var nav
var alertPath = []
var alertPath_idx = 0

var spotPath = []
var spot_idx = 0

var sniffPath = []
var sniffPath_idx = 0
var sniffLoc = null

#Alerts, spots, and being attacked forces state options

func _ready():
	add_to_group("Shootables")
	add_to_group("Hearables")

func _process(delta):
	if(!isAlive):
		return
	if isSpotted():
		if isCharged(spottedLoc):
			charged.call_funcv([delta])
			return
		if(!blockSpotted):
			spotted.call_funcv([delta])
		return
	if isAlerted():
		if(alertPath == null):
			alertPath_idx = 0
			alertPath = nav.get_simple_path(translation, alertLoc)
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
			checkNeighbours(delta)
			checkCollision(move_and_collide(transform.basis.x * speed * delta))

func checkCollision(curCollision):
	if(curCollision != null):
		if(isAlerted() || isSpotted()):
			if(friends.find(curCollision.collider) > -1):
				if(!curCollision.collider.isAlerted() && !curCollision.collider.isSpotted() ):
					curCollision.collider.setAlert(alertLoc,lastSpotted)

func checkNeighbours(_delta):
	var i = 0
	var sum = Vector3(0,0,0)
	for e in friends:
		if(e != self):
			var d = translation.distance_to(e.translation)
			if(d < seperation):
				var diffVec = translation - e.translation
				diffVec = diffVec.normalized()
				i += 1
				sum += diffVec/d
	if(i > 0):
		var res = sum/i
		turnTowards(translation + res.normalized(),PI/2*_delta)

#must be invoked by physics thread
#Adds the nearest ETarget that enemy has a 180 degree line of sight on
func look(space_state):
	var closest = 99999
	var current = null
	var tempDist
	for dude in targets:
		var ray = space_state.intersect_ray(translation,dude.translation,[self])
		if(ray.collider_id == dude.get_instance_id()):
			tempDist = translation.distance_to(dude.translation)
			if(Vector3(1,0,0).dot(to_local(dude.translation)) > 0):
				if(tempDist < closest):
					current = dude
					closest = tempDist
	if(current != null):
		var freshSpot = (spottedChar == null)
		setSpot(current.translation, current)
		setAlert(spottedLoc,spottedChar)
		if(freshSpot):
			spot_idx = 0
			spotPath = nav.get_simple_path(translation, spottedLoc)
			targetLoc = spotPath[spot_idx]
		hasInSight(space_state,freshSpot)
	else:
		
		hasLostSight(space_state)
		spottedLoc = null
		spottedChar = null

func pulse():
	pass

#Good for overriding
func reachedEndOfAlertedPath(_delta):
	pass

func hasLostSight(space_state):
	pass

func hasInSight(space_state, freshSpot):
		signalOthers(space_state,20)

#Notify friendlies that can see me of an enemy position
func signalOthers(space_state, distance_limit):
	for f in friends:
		if(!f.isAlive):
			continue
		if(f.isSpotted()):
			continue
		if(translation.distance_to(f.translation) > distance_limit):
			continue
		if(Vector3(1,0,0).dot(f.to_local(translation)) > 0):
			if(f.isAlerted()):
				if(f.alertLoc.distance_to(spottedLoc) < 5):
					continue
			var ray = space_state.intersect_ray(translation,f.translation,[self])
			if(ray.collider_id == f.get_instance_id()):
				f.setAlert(spottedLoc, spottedChar)

#STATE CHECKS

func isIdle():
	return (alertLoc == null && spottedLoc == null)

func isAlerted():
	return (alertLoc != null)

func isSpotted():
	return (spottedLoc != null)

func isCharged(loc):
	return (translation.distance_to(loc) < proximity)

#BASIC OPS

func hit(dam):
	health -= dam
	if(health <= 0):
		death()

func death():
	isAlive = false
	rotation.x = PI/2

#By default this will alert to the originating object
func heardSound(loc, origin):
	setAlert(loc, origin)

func setAlert(loc , origin):
	alertLoc = loc
	lastSpotted = origin
	alertPath = null

func setSpot(loc, origin):
	spottedLoc = loc
	spottedChar = origin

func clearSniff():
	sniffLoc = null
	sniffPath = []
	sniffPath_idx = 0

#IDLE

func wait():
	speed = 0

func meander(_delta):
	targetLoc = randomLoc
	if(translation.distance_to(targetLoc) > walk):
		speed = walk
	else:
		speed = 0

func patrol(_delta):
	pass

#ALERTED

func pursue(_delta):
	if(alertPath_idx < alertPath.size() && translation.distance_to(alertPath[alertPath_idx]) < 5):
		alertPath_idx = stepPath(alertPath, alertPath_idx, alertLoc)
	elif (translation.distance_to(alertLoc) < 5):
			speed = 0
			reachedEndOfAlertedPath(_delta)
			return
	speed = run

func approach(_delta):
	pursue(_delta)
	speed = walk

# this is basically approach, but the path must be set by the personality
func sniff(_delta):
	if(sniffPath_idx == 0):
		targetLoc = sniffPath[0]
	if(sniffPath_idx < sniffPath.size()-1 && translation.distance_to(sniffPath[sniffPath_idx]) < walk):
		sniffPath_idx += 1
		targetLoc = sniffPath[sniffPath_idx]
	elif (translation.distance_to(sniffPath[sniffPath.size()-1]) < 5):
			sniffPath_idx = sniffPath.size()
			speed = 0
			return
	speed = walk*2


func flee(_delta):
	pass

#SPOTTED

func charge(_delta):
	#if our last step in the path has drifted to far from the target replan
	if(spottedChar.translation.distance_to(spotPath[spotPath.size()-1]) > 5):
		spotPath = nav.get_simple_path(translation,spottedLoc)
		spot_idx = 0
		targetLoc = spotPath[spot_idx]
	if(spot_idx < spotPath.size() && translation.distance_to(spotPath[spot_idx]) < 5):
		spot_idx = stepPath(spotPath, spot_idx, spottedLoc)
	speed = run

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
	if(!canAttack):
		return false
	canAttack = false
	return true

func withdraw(_delta):
	speed = -walk
	targetLoc = spottedLoc

#UTILITIES

func stepPath(path, pathIdx, finDest):
	pathIdx += 1
	if(pathIdx == path.size()):
		targetLoc = finDest
	else:
		targetLoc = path[pathIdx]
	return pathIdx

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
