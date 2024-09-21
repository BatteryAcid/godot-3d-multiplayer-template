extends State

func process_physics(delta: float, tick, is_fresh: bool, current_frame): # -> State:
	var movement_input: Vector2 = get_movement_input()
	#print("[IDLE] %s, tick: %s, frame: %s, fresh?: %s" % [movement_input, tick, current_frame, is_fresh])
	
	rotate_player_model(delta)
