extends Area

var origin = Inventory.player

func _ready():
	origin = Inventory.player
	pass # Replace with function body.

#func _process(delta):
#	pass

func _on_AudioStreamPlayer3D_finished():
	get_parent().remove_child(self)
	call_deferred("free")


func _on_Area_body_entered(body):
	if(body.is_in_group("Enemies")):
		body.heardSound(translation, origin)
	pass # Replace with function body.
