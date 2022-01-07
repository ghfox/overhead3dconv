extends KinematicBody

class_name Enemy

var health = 10

func hit(dam):
	health -= dam
	if(health <= 0):
		death()

func death():
	rotate_x(90)
