extends Node2D

@onready var mouse_crosshair : Node = $Mouse_Crosshair
@onready var gamepad_arrow : Node = $Gamepad_Arrow
var aim_direction = Vector2(0,0)
var is_mouse :bool = true

func _ready():
	Input_Mode.input_mode_changed.connect(_on_input_mode_changed)
	gamepad_arrow.hide()

func _process(delta):
	control_view_of_aim()

func _on_input_mode_changed(new_device):
	if new_device == 0:
		mouse_crosshair.show()
		gamepad_arrow.hide()
		is_mouse = true
	else:
		mouse_crosshair.hide()
		is_mouse = false
		
func get_aim_direction() -> Vector2:
	if is_mouse == true:
		return get_mouse_aim()
	else:
		return get_gamepad_aim()

func get_mouse_aim() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - global_position).normalized()

var last_aim_dir := Vector2.RIGHT

func get_gamepad_aim() -> Vector2:
	var dir = Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		)
		
	#if dir.length() == 0:
		#return last_aim_dir
		
	last_aim_dir = dir.normalized()
	return last_aim_dir

func control_view_of_aim():
	if is_mouse == true:
		mouse_crosshair.global_position = get_global_mouse_position()
	
	else:
		var pad_dir = get_gamepad_aim()
		
		if pad_dir == Vector2(0, 0):
			gamepad_arrow.hide()
			
		else:
			gamepad_arrow.show()
			gamepad_arrow.rotation = pad_dir.angle()
