class_name State extends Node

# Source: https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines

@export var animation_name: String
@export var move_speed: float = 400
@export var state_name: String
@export var camera_input : CameraInput
@export var player_model : Node3D

const WALK_SPEED := 5.0
const RUN_MODIFIER := 2.5
const ROTATION_INTERPOLATE_SPEED := 10

var gravity: int = ProjectSettings.get_setting("physics/3d/default_gravity")

var animation_player: AnimationPlayer
var move_component
var parent: Player

func enter() -> void:
	if animation_name != "" && animation_player != null:
		animation_player.play(animation_name)

func exit() -> void:
	animation_player.stop()

func process_input(event: InputEvent) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func process_physics_client(delta: float):
	pass

func get_movement_input() -> Vector2:
	return move_component.input_dir

func get_jump() -> float:
	return move_component.jump_input

func get_run() -> bool:
	return move_component.run_input
	
func apply_gravity(delta):
	if not parent.is_on_floor():
		parent.velocity.y -= gravity * delta

func rotate_player_model(delta: float) -> Basis:
	var camera_basis : Basis = camera_input.get_camera_rotation_basis()
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
		var q_to = camera_input.get_camera_base_quaternion()
		# Interpolate current rotation with desired one.
		parent.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	parent.orientation.origin = Vector3()
	parent.orientation = parent.orientation.orthonormalized()
	player_model.global_transform.basis = parent.orientation.basis
	
	return camera_basis

func apply_player_rotation_client(delta: float):
	# Smooths out players (model) rotation on clients
	var from = player_model.global_transform.basis
	var to = parent.orientation.basis.get_rotation_quaternion()
	var model_transform = Basis(from.slerp(to, delta * ROTATION_INTERPOLATE_SPEED))
	model_transform = model_transform.orthonormalized()
	player_model.global_transform.basis = model_transform

func move_player(delta: float, camera_basis: Basis, speed = WALK_SPEED):
	camera_basis = camera_basis.rotated(camera_basis.x, -camera_basis.get_euler().x)
	
	var input_dir = get_movement_input()
	
	var direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var position_target = direction * speed
	
	if get_run():
		position_target *= RUN_MODIFIER
		
	var horizontal_velocity = parent.velocity
	horizontal_velocity.y = 0
	horizontal_velocity = horizontal_velocity.lerp(position_target, 10 * delta)
	
	if horizontal_velocity:
		parent.velocity.x = horizontal_velocity.x
		parent.velocity.z = horizontal_velocity.z
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, speed)
		parent.velocity.z = move_toward(parent.velocity.z, 0, speed)

	parent.move_and_slide()
