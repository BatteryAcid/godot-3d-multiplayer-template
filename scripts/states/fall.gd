extends State

const FALL_MOVE_SPEED := 2.0

func process_physics(delta: float, tick, is_fresh: bool, current_frame):
	var movement_input: Vector2 = get_movement_input()
	#print("[FALL] %s, tick: %s, frame: %s, fresh?: %s" % [movement_input, tick, current_frame, is_fresh])
	
	apply_gravity(delta)
	rotate_player_model(delta)
	move_player(delta, movement_input, FALL_MOVE_SPEED)
