extends Area

var origin = Inventory.player
var sound = ""
var location = Vector3(0,0,0)
var radius = 1

func init(snd, loc, org, rad):
	sound = snd
	location = loc
	origin = org
	radius = rad

func _ready():
	translation = location
	$AudioStreamPlayer3D.stream = load(sound)
	$AudioStreamPlayer3D.set_pitch_scale(Engine.time_scale)
	$CollisionShape.scale = Vector3(radius, 1, radius)


func _on_AudioStreamPlayer3D_finished():
	get_parent().remove_child(self)
	call_deferred("free")

func _on_Area_body_entered(body):
	if(body.is_in_group("Hearables")):
		body.heardSound(translation, origin)
	pass # Replace with function body.
