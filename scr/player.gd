extends CharacterBody3D

var speed = 12
var JUMP_VELOCITY = 8
var gravity = 19
var pickedObject
const SENSITIVITY =0.004
signal interact_object
@onready var ray_cast_3d: RayCast3D = $Head/Camera3D/RayCast3D


@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D


func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _input(event):
	if event.is_action_pressed("interaction") and pickedObject:
		pickedObject.reparent(get_tree().current_scene)
		pickedObject = null


func _physics_process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		interact_object.emit(collider)

	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	move_and_slide()	
	
func pick_up_object(object):
	object.reparent(self)
	object.global_position = $Head/CarryObjectMarker.global_position
	
	await get_tree().create_timer(0.1).timeout
	pickedObject = object
