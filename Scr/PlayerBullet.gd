extends KinematicBody

var SPEED = 10
var DAM = 10.0
var PEN = 1.0
var DIR = 360
var LIFESPAN = 0.5
var velocity = Vector3(0,0,0)

func _ready():
	rotate_y(DIR)
	$Timer.start(LIFESPAN)
	if(randi() % 2 == 1):
		AudioManager.playASA(AudioManager.gunshot1, translation, Inventory.player, 15)
		pass
	else:
		AudioManager.playASA(AudioManager.gunshot2, translation, Inventory.player, 15)
		pass


func _physics_process(delta):
	var event = move_and_collide(transform.basis.x * SPEED * delta)
	if(event != null):
		if(event.collider.is_in_group("BulletStops")):
			delme()
		if(event.collider.is_in_group("Shootables")):
			var damage = DAM * clamp((PEN / event.collider.armor),0.0,1.0)
			event.collider.hit(damage)
			delme()

func delme():
	get_parent().remove_child(self)
	call_deferred("free")

func _on_Timer_timeout():
	get_parent().remove_child(self)
	call_deferred("free")
