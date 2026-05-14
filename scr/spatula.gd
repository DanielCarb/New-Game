extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var selected = false
var player
var animating = false
var pickedUp = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and selected:
		player.pick_up_object(self)
		pickedUp = true
	if event.is_action_pressed("click") and player == get_parent() and not animating:
		_play_flip()

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player.interact_object.connect(_set_selected)

func _play_flip():
	animating = true
	var tween = create_tween()
	tween.tween_property(self, "rotation:x", deg_to_rad(-60), 0.15)  # tilt down
	tween.tween_property(self, "rotation:x", deg_to_rad(10), 0.15)   # flick up
	tween.tween_property(self, "rotation:x", deg_to_rad(-30), 0.2)   # settle back
	await tween.finished
	animating = false

func _physics_process(delta: float) -> void:
	if pickedUp: return  # we'll set this flag instead
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func _set_selected(object):
	selected = self == object
