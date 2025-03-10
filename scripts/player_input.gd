class_name PlayerInput extends Node

var input_dir : Vector2 = Vector2.ZERO
var jump_input := false
var run_input := false

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	# In this case, should be client authority
	if is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		jump_input = Input.is_action_pressed("jump")
		run_input = Input.is_action_pressed("run")

func _exit_tree():
	NetworkTime.before_tick_loop.disconnect(_gather)
