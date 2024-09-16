# TODO:
# Adding jump and run to lag comp 
# fix animation bug where it animates walk on other client, when player is idle
class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var _player_input : PlayerInput
@export var _camera_input : CameraInput
@export var _player_model : Node3D
@export var _movement_sm : Node 

var orientation = Transform3D()

func _enter_tree():
	_player_input.set_multiplayer_authority(str(name).to_int())
	_camera_input.set_multiplayer_authority(str(name).to_int())

func _ready():
	
	var animation_player = _player_model.get_node("AnimationPlayer")
	_movement_sm.init(self, _player_input, animation_player)

#func _unhandled_input(event: InputEvent) -> void:
	#if is_multiplayer_authority():
		#print("Unhandled input hit on peer %s for client %s" % [multiplayer.get_unique_id(), name])
		#_movement_sm.process_input(event)

func _rollback_tick(delta, tick, is_fresh):
	_movement_sm.process_physics(delta)
	
	#if not is_multiplayer_authority():
		#_movement_sm.process_physics_client(delta)

#func _physics_process(delta):
	#if is_multiplayer_authority():
		## NOT NEEDED _movement_sm.process_input(null)
		#_movement_sm.process_physics(delta)
	#else:
		#_movement_sm.process_physics_client(delta)
