extends State

const JUMP_VELOCITY := 6.5
const JUMP_MOVE_SPEED := 3.0

func process_physics(delta: float, tick, is_fresh: bool, current_frame): # -> State:
	var movement_input: Vector2 = get_movement_input()
	#print("[JUMP] %s, tick: %s, frame: %s, fresh?: %s" % [movement_input, tick, current_frame, is_fresh])
	
	parent.velocity.y = JUMP_VELOCITY
	rotate_player_model(delta)
	move_player(delta, movement_input, JUMP_MOVE_SPEED)
