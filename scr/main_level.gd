extends Node3D
var testTexs = [
	preload("res://Assets/WELcum.png"),
	preload("res://Assets/press_E.png"),
	preload("res://Assets/GOOD_JB.png")
]

func _ready() -> void:
	$Text.texture = testTexs[0]
	await get_tree().create_timer(2.0).timeout
	$Text.texture = testTexs[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("e") && $Text.texture == testTexs[1]:
		$Text.texture = testTexs[2]
