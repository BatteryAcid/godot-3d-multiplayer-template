class_name State extends Node

# Source: https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines

@export var animation_name: String
@export var move_speed: float = 400

@export var state_name: String

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
	return move_component.input_dir # move_component.get_movement_direction()

func get_jump() -> float:
	return move_component.jump_input #wants_jump()
