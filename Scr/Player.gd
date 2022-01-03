extends KinematicBody

var HUD

var move = Vector3(0,0,0)
var playerBullet = preload("res://Scn/PlayerBullet.tscn")
var reloadAnim = preload("res://Scn/ReloadAnim.tscn")

var focusAbilityPressed = false
var reloading = false
var reloader = null

var canGrab = null

var userInInventory = false

func _ready():
	$Camera.set_as_toplevel(true)
	HUD = get_node("GUI/HUD")
	Inventory.player = self
	
	#ItemPick test garbage
	var new 
	new = ItemPickup.new(Ammo.new("9mm","fmj",10))
	new.translation.x = 0 
	get_parent().call_deferred("add_child_below_node",self,new)
	new = ItemPickup.new(Ammo.new("9mm","fmj",10))
	new.translation.x = 1 
	get_parent().call_deferred("add_child_below_node",self,new)
	new = ItemPickup.new(Magazine.new("9mm 10rd Mag"))
	new.translation.x = -2 
	get_parent().call_deferred("add_child_below_node",self,new)

func _process(_delta):
	camera_follow()
	if(userInInventory): 
		return			#for now let's abort all inputs if inventory
	rotation = Controller.getCursorAngle(get_viewport().get_camera().unproject_position(translation) , get_viewport().get_mouse_position() )
	move = Controller.getMove() * (StatStore.MAX_SPEED)
	move_and_slide(move)
	if(!reloading):
		if(Input.get_action_strength(Controller.actionAttack) > 0.5):
			attack()
	if(canGrab != null):
		updateGrabs()

func attack():
	if($Shottimer.time_left == 0):
		var hand = Inventory.hand
		if(hand.type == "weapon"):
			if(hand.cat == "pistol"):
				if(hand.fire()):
					spawnBullet(hand)
		print(Inventory.pack)
		print(Inventory.pocket)
		print(Inventory.hand)

func spawnBullet(hand):
	$Shottimer.start(hand.cooldown)
	var newBullet = playerBullet.instance()
	newBullet.translation = translation + (Vector3(cos(rotation.y), 0, -sin(rotation.y)) * 1)
	newBullet.DIR = rotation.y
	newBullet.DAM = hand.dam
	newBullet.SPEED = hand.muzzle
	get_parent().add_child_below_node(self,newBullet)

func _input(_event):
	if(userInInventory):
		return
	if(Input.is_action_just_pressed(Controller.actionFocusAbility)):
		focusActive()
	elif(Input.is_action_just_released(Controller.actionFocusAbility)):
		focusInactive()
	elif(Input.is_action_just_pressed(Controller.actionReload)):
		reload()
	elif(Input.is_action_just_pressed(Controller.nextPocket)):
		Inventory.nextPocket()
		HUD.updateSelectedPocket()
	elif(Input.is_action_just_pressed(Controller.actionPickup)):
		grabItem()
	elif(Input.is_action_just_released(Controller.inventory)):
		enterInventory()

func enterInventory():
	userInInventory = true

func grabItem():
	if(canGrab != null):
		var pickup = canGrab
		canGrab = null
		var p = Inventory.findEmptyPocket()
		if(p  > -1):
			Inventory.moveToPocket(pickup.item,p)
			HUD.updatePocketGrid()
		else:
			Inventory.addToPack(pickup.item)
		pickup.free()
		updateGrabs()

func reload():
	if(reloading):
		reloader.skip()
	else:
		if(Inventory.findNextMag()):
			reloading = true
			reloader = reloadAnim.instance()
			get_parent().get_node("LayerUnMod").add_child(reloader)

func focusActive():
	Engine.time_scale = 0.5
	AudioManager.repitch()

func focusInactive():
	Engine.time_scale = 1.0
	AudioManager.repitch()

func _on_Detector_area_entered(area):
	if(area.is_in_group("Grabables")):
		area.add_to_group("GrabNows")
	updateGrabs()

func _on_Detector_area_exited(area):
	if(area.is_in_group("Grabables")):
		area.remove_from_group("GrabNows")

func updateGrabs():
	var nearest = null
	var dist = 999
	var tdist = 0
	for n in get_tree().get_nodes_in_group("GrabNows"):
		#tdist = position.distance_to(n.position)
		if(dist > tdist):
			dist = tdist
			nearest = n
	if(nearest != canGrab):
		if(canGrab != null):
			canGrab.turnOffOutline()
		canGrab = nearest
		if(canGrab != null):
			canGrab.turnOnOutline()

func camera_follow():
	$Camera.translation.x = translation.x
	$Camera.translation.z = translation.z + 15
