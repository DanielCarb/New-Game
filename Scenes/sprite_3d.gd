extends CharacterBody3D

@export var speed = 1.5
@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"
@onready var timer: Timer = $"../Timer"


enum State {IDLE, WALKING}
var state = State.IDLE
var walking_duration = 5
var idle_duration = 5

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start(idle_duration)
	
func _on_timer_timeout():
	match state:
		State.IDLE:
			var random_target = Vector3 (randf_range (-10, 10), 0, randf_range(-10, 10))
			nav_agent.target_position= random_target
			state = State.WALKING
			timer.start(idle_duration)
		State.WALKING:
			state = State. IDLE
func process(delta: float) -> void:
	if state== State.WALKING:
		if nav_agent.is_navigation_finished():
			state= State.IDLE
			timer.start(idle_duration)
		else:
			move_toward_target(speed)
func move_toward_target (move_speed):
	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position- global_transform.origin).normalized()
	var velocity = direction * move_speed
	move_and_slide()
	if direction.length()>0:
		var target_rotation = global_transform.looking_at (next_position). basis
		global_transform. basis = global_transform.basis.slerp(target_rotation, 0.1)
