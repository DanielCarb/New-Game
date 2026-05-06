extends CharacterBody3D

@export var speed = 5
@export var idle_duration = 3.0
@export var walk_area_size = 40.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer

enum State { IDLE, WALKING }
var state = State.IDLE

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start(idle_duration)

func _on_timer_timeout() -> void:
	# Timer only fires when IDLE — pick a new destination and start walking
	var random_target = Vector3(
		randf_range(-walk_area_size, walk_area_size),
		0,
		randf_range(-walk_area_size, walk_area_size)
	)
	nav_agent.target_position = random_target
	state = State.WALKING

func _physics_process(_delta: float) -> void:
	if state == State.WALKING:
		if nav_agent.is_navigation_finished():
			# Reached the target — go idle and start the rest timer
			state = State.IDLE
			velocity = Vector3.ZERO
			timer.start(idle_duration)
		else:
			_move_toward_target()

func _move_toward_target() -> void:
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	# Assign to self.velocity so move_and_slide() uses it
	velocity = direction * speed
	move_and_slide()

	# Rotate to face movement direction (guard against zero-length direction)
	if direction.length() > 0.01:
		var target_basis = global_transform.looking_at(next_pos, Vector3.UP).basis
		global_transform.basis = global_transform.basis.slerp(target_basis, 0.1)
