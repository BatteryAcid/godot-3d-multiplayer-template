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

func process_physics(delta: float, tick, is_fresh: bool, current_frame):
	return null

func get_movement_input() -> Vector2:
	return move_component.input_dir

func get_jump() -> float:
	return move_component.jump_input

func get_run() -> bool:
	return move_component.run_input
	
func apply_gravity(delta):
	parent.velocity.y -= gravity * delta

func rotate_player_model(delta: float):
	var camera_basis : Basis = camera_input.camera_basis
	
	# NOTE: Model direction issues can be resolved by adding a negative to camera_z, depending on setup.
	var player_lookat_target = -camera_basis.z
	
	var q_from = parent.orientation.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(player_lookat_target, Vector3.UP).basis.get_rotation_quaternion()
	
	parent.orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))

	player_model.global_transform.basis = parent.orientation.basis

func move_player(delta: float, movement_input, speed = WALK_SPEED):

	var input_dir : Vector2 = movement_input

	# Based on https://github.com/godotengine/godot-demo-projects/blob/4.2-31d1c0c/3d/platformer/player/player.gd#L65
	var direction = (camera_input.camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var position_target = direction * speed
	
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

