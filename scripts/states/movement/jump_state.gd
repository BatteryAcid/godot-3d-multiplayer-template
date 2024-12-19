extends MovementState

func enter(previous_state: RewindableState, tick: int) -> void:
	parent.velocity.y = JUMP_VELOCITY

func tick(delta, tick, is_fresh):
	rotate_player_model(delta)
	move_player(delta)
	
	force_update_is_on_floor()
	if not parent.is_on_floor():
		state_machine.transition(&"FallState")
	# If issues arise around jump, add additional state transitions here

func move_player(delta: float, speed = WALK_SPEED):
	var input_dir : Vector2 = get_movement_input()
	
	# Based on https://github.com/godotengine/godot-demo-projects/blob/4.2-31d1c0c/3d/platformer/player/player.gd#L65
	var direction = (camera_input.camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var position_target = direction * speed
	
	# Here I'm allowing "run speed" to be applied to jump
	if get_run():
		position_target *= RUN_MODIFIER
		
	var horizontal_velocity = parent.velocity
	horizontal_velocity = position_target
	
	if horizontal_velocity:
		parent.velocity.x = horizontal_velocity.x
		parent.velocity.z = horizontal_velocity.z
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, speed)
		parent.velocity.z = move_toward(parent.velocity.z, 0, speed)

	# https://foxssake.github.io/netfox/netfox/tutorials/rollback-caveats/#characterbody-velocity
	parent.velocity *= NetworkTime.physics_factor
	parent.move_and_slide()
	parent.velocity /= NetworkTime.physics_factor
