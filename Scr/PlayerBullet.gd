extends KinematicBody

var SPEED = 10
var DAM = 100
var DIR = 360
var LIFESPAN = 0.5
var velocity = Vector3(0,0,0)

func _ready():
	rotation.y = DIR
	velocity = Vector3(cos(DIR),0, -sin(DIR)) * SPEED
	$Timer.start(LIFESPAN)
	if(randi() % 2 == 1):
		AudioManager.play(AudioManager.gunshot1)
	else:
		AudioManager.play(AudioManager.gunshot2)


func _physics_process(delta):
	var event = move_and_collide(velocity * delta)
	if(event != null):
		if(event.collider.is_in_group("BulletStops")):
			get_parent().remove_child(self)
			call_deferred("free")

func _on_Timer_timeout():
	get_parent().remove_child(self)
	call_deferred("free")
