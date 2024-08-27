extends State

@export var _move_state : State

const JUMP_VELOCITY := 4.5

var jumped := false
var jump_wait := 0.0

# TODO: add "fall" state to transition to after we apply upward jump
# - try adding minimal movement input so player can move while falling
# - could probably remove jump_wait stuff, and just immediately transition to the fall state
func process_physics(delta: float) -> State:
	if parent.is_on_floor():
		parent.velocity.y = JUMP_VELOCITY * get_jump()
	else:
		jump_wait += delta
	
	parent.move_and_slide()
	
	if jump_wait > 0.5:
		jump_wait = 0
		return _move_state
	return null
