extends Node

var AlertSoundArea = preload("res://Scn/AlertSoundArea.tscn")

var gunshot1 = "res://Audio/gunshot1.wav"
var gunshot2 = "res://Audio/gunshot2.wav"

func playASA(snd, loc, org, radius):
	var newSound = AlertSoundArea.instance()
	newSound.init(snd, loc, org, radius)
	Inventory.player.get_parent().add_child(newSound)
	

func repitch():
	for i in get_tree().get_nodes_in_group("SFX"):
		i.set_pitch_scale(Engine.time_scale)
