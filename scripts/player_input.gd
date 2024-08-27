class_name PlayerInput extends Node

var input_dir : Vector2 = Vector2.ZERO
var jump_input := 0.0 
var run_input := false

func _physics_process(delta):
	# In this case, should be client authority
	if is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		jump_input = Input.get_action_strength("jump")
		run_input = Input.is_action_pressed("run")
