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
	rotate_x(90)

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
