extends State

@export var _move_state : State

const FALL_MOVE_SPEED := 2.0

# NOTE: this may eventually go away in favor of using a single move/rotation function with lag compensation impl
func process_physics_client(delta: float):
	apply_player_rotation_client(delta)
	
func process_physics(delta: float) -> State:
	apply_gravity(delta)
	
	var camera_basis = rotate_player_model(delta)
	move_player(delta, camera_basis, FALL_MOVE_SPEED)
	
	if parent.is_on_floor():
		return _move_state
	return null
