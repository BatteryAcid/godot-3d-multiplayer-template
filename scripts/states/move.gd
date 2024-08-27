extends State

@export var _idle_state : State
@export var _jump_state : State

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const ROTATION_INTERPOLATE_SPEED := 10

# TODO: consider moving to State superclass
@export var _camera_input : CameraInput
@export var _player_model : Node3D

func process_physics_client(delta: float):
	#print("hereasdf")
	# Smooths out players (model) rotation on clients
	var from = _player_model.global_transform.basis
	var to = parent.orientation.basis.get_rotation_quaternion()
	var model_transform = Basis(from.slerp(to, delta * ROTATION_INTERPOLATE_SPEED))
	model_transform = model_transform.orthonormalized()
	_player_model.global_transform.basis = model_transform

func process_physics(delta: float) -> State:

	_apply_gravity(delta)

	if get_jump() > 0:
		return _jump_state
		
	# NOTE: changed to use input threshold for idle transition
	# if parent.velocity.length() < 0.01:
	elif get_movement_input() == Vector2.ZERO and parent.is_on_floor():
		print("Move state transition to idle")
		return _idle_state
		
	var camera_basis : Basis = _camera_input.get_camera_rotation_basis()
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	# NOTE: Model direction issues can be resolved by adding a negative to camera_z, depending on setup.
	var player_lookat_target = -camera_z
	
	if player_lookat_target.length() > 0.001:
		var q_from = parent.orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(player_lookat_target, Vector3.UP).basis.get_rotation_quaternion()
		
		parent.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	else:
		# TODO: this will need to be in idle state, probably remove it from here too
		# Rotates player even if standing still
		var q_from = parent.orientation.basis.get_rotation_quaternion()
		var q_to = _camera_input.get_camera_base_quaternion()
		# Interpolate current rotation with desired one.
		parent.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	parent.orientation.origin = Vector3()
	parent.orientation = parent.orientation.orthonormalized()
	_player_model.global_transform.basis = parent.orientation.basis
	
	# movement
	var horizontal_velocity = parent.velocity
	horizontal_velocity.y = 0
	
	camera_basis = camera_basis.rotated(camera_basis.x, -camera_basis.get_euler().x)
	
	var input_dir = get_movement_input() #_player_input.input_dir
	
	var direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var position_target = direction * SPEED
	
	#if _player_input.run_input:
		#position_target *= 1.5
	horizontal_velocity = horizontal_velocity.lerp(position_target, 10 * delta)
	
	if horizontal_velocity:
		parent.velocity.x = horizontal_velocity.x
		parent.velocity.z = horizontal_velocity.z
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, SPEED)
		parent.velocity.z = move_toward(parent.velocity.z, 0, SPEED)

	parent.move_and_slide()
		
	return null

func _apply_gravity(delta):
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta
