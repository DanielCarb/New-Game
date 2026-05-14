extends CharacterBody3D
var speed = 12
var JUMP_VELOCITY = 8
var gravity = 19
var pickedObject
const SENSITIVITY = 0.004
signal interact_object
@onready var shape_cast: ShapeCast3D = $Head/Camera3D/ShapeCast3D
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var carry_marker: Node3D = $Head/Camera3D/CarryObjectMarker

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
	pass

func _physics_process(delta: float) -> void:
	# ShapeCast selection
	if shape_cast.is_colliding():
		interact_object.emit(shape_cast.get_collider(0))
	else:
		interact_object.emit(null)

	# Keep held object locked to camera position and rotation
	if pickedObject:
		pickedObject.global_position = carry_marker.global_position
		pickedObject.global_rotation = Vector3(camera_3d.global_rotation.x + deg_to_rad(-60), head.global_rotation.y, 0)

	if not is_on_floor():
		velocity.y -= gravity * delta
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
	object.global_position = carry_marker.global_position
	await get_tree().create_timer(0.1).timeout
	pickedObject = object
