extends State

@export var _idle_state : State
@export var _jump_state : State
@export var _fall_state : State

# NOTE: this may eventually go away in favor of using a single move/rotation function with lag compensation impl
func process_physics_client(delta: float):
	apply_player_rotation_client(delta)

func process_physics(delta: float) -> State:

	apply_gravity(delta)

	if get_jump() > 0:
		return _jump_state
		
	# NOTE: changed to use input threshold for idle transition
	# if parent.velocity.length() < 0.01:
	elif get_movement_input() == Vector2.ZERO and parent.is_on_floor():
		return _idle_state
	elif not parent.is_on_floor():
		return _fall_state

	# player rotation
	var camera_basis = rotate_player_model(delta)
	
	# movement
	move_player(delta, camera_basis)

	return null
