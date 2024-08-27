extends State

@export var _move_state : State
@export var _jump_state : State
@export var _fall_state : State

func enter() -> void:
	super()
	parent.velocity = Vector3.ZERO

# TODO: may not need to use process input, revisit, as we use synchronizer to pass player input
# TODO: if this refactor works remove event
func process_input(event: InputEvent) -> State:
	#if get_movement_input() != Vector2.ZERO:
		#print("started moving %s" % parent.name)
		#return _move_state
	return null
	
# NOTE: this may eventually go away in favor of using a single move/rotation function with lag compensation impl
func process_physics_client(delta: float):
	apply_player_rotation_client(delta)

func process_physics(delta: float) -> State:
	if parent.is_on_floor():
		if get_jump() > 0:
			return _jump_state
		elif get_movement_input() != Vector2.ZERO:
			# print("started moving %s" % parent.name)
			return _move_state
	else:
		apply_gravity(delta)
		return _fall_state
	
	rotate_player_model(delta)
	parent.move_and_slide()

	return null
