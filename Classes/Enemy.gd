extends KinematicBody

class_name Enemy

var health = 10
var walk = 1
var run = 3
var circleToLunge = true	#Does circling close or maintain dist?
var circleDist = 3			#Dist to circle at
var maxCircleDist = 5		#Maximum distance while circling
var hunter = true			#Pursues fast
var alertLoc = null			#Loc of most recent alert
var spottedLoc = null		#Loc of spotted
var proximity = 1			#Dist to trigger charged
var wasCharged = false		#Charged flag
var isAlive = true

var speed = 0
var targetLoc = null
var flankRight = true

#Alerts, spots, and being attacked forces state options

func pulse():
	pass

func isIdle():
	return (alertLoc == null && spottedLoc == null)

func isAlerted():
	return (alertLoc != null)

func isSpotting():
	return (spottedLoc != null)

func hit(dam):
	health -= dam
	if(health <= 0):
		death()

func death():
	isAlive = false
	rotation.x = PI/2

func wait():
	speed = 0

func meander():
	if(randi()%2==1):
		speed = walk
	else:
		speed = 0 

func patrol():
	pass

func hunt():
	speed = run
	targetLoc = alertLoc

func approach():
	speed = walk
	targetLoc = alertLoc

func flee():
	pass

func charge():
	speed = run
	targetLoc = spottedLoc

func maintain():
	speed = 0
	targetLoc = spottedLoc

func circle():
	flankRight = randi()%2==1
	if(circleToLunge):
		speed = run
	else:
		speed = walk

func lunge():
	pass

func withdraw():
	pass

func turnTowards(targetVec, delta):
	var final = (targetVec - translation)
	var temp = lerp_angle(rotation.y, atan2(-final.z,final.x), 1 * delta) - rotation.y
	rotate_y(temp)

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
