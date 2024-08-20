extends State

@export var _move_state : State

func enter() -> void:
	super()
	parent.velocity = Vector3.ZERO

# TODO if this refactor works remove event
# Revisit
func process_input(event: InputEvent) -> State:
	if get_movement_input() != Vector2.ZERO:
		print("started moving %s" % parent.name)
		return _move_state
	return null

func process_physics(delta: float) -> State:
	_apply_gravity(delta)
	parent.move_and_slide()
	
	#if !parent.is_on_floor():
		#return fall_state
	return null

func _apply_gravity(delta):
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
