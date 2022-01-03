extends Area

class_name ItemPickup

var item
var shader
var mat

func _init(newItem):
	item = newItem
	rotation.y = (randi() % 60) / 10.0
	translation.y = 1.5
	pass

func _ready():
	var collider = CollisionShape.new()
	var circ = SphereShape.new()
	circ.set_radius(item.radius)
	collider.set_shape(circ)
	add_child(collider)
	
	var mesh = MeshInstance.new()
	mesh.set_mesh(CubeMesh.new())
	mat = SpatialMaterial.new()
	mat.set_albedo(Color(0.5,0,0.25,1))
	shader = ShaderMaterial.new()
	shader.set_shader(load("res://Shaders/3dOutline.gdshader"))
	shader.set_shader_param("color", Color(0,1,0,1))
	
	mesh.set_surface_material(0,mat)
	add_child(mesh)
	
	set_name("%s%s" % ["ItemPickup-",item])
	add_to_group("Grabables", false)
	pass

func turnOnOutline():
	#shader.set_shader_param("enable", true)
	mat.set_next_pass(shader)

func turnOffOutline():
	#shader.set_shader_param("enable", false)
	mat.set_next_pass(null)
