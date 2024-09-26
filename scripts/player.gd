class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var _player_input : PlayerInput
@export var _camera_input : CameraInput
@export var _player_model : Node3D
@export var _movement_sm : Node
#@export var current_state : State # Moved to synching current_state_id instead of object
@export var current_state_id : String

# States
@export var _idle_state : State
@export var _move_state : State
@export var _jump_state : State
@export var _fall_state : State

@onready var rollback_synchronizer = $RollbackSynchronizer

func _enter_tree():
	_player_input.set_multiplayer_authority(str(name).to_int())
	_camera_input.set_multiplayer_authority(str(name).to_int())

func _ready():
	
	# Init state to idle to establish current_state_id
	set_current_state(_idle_state)
	
	var animation_player = _player_model.get_node("AnimationPlayer")
	_movement_sm.init(self, _player_input, animation_player)
	
	# call this after setting authority
	# https://foxssake.github.io/netfox/netfox/tutorials/responsive-player-movement/#ownership
	rollback_synchronizer.process_settings()

func _rollback_tick(delta, tick, is_fresh):
	var current_state = get_current_state()
	var movement_input: Vector2 = _player_input.input_dir #current_state.get_movement_input()
	
	var new_state : State = _determine_state(movement_input, current_state)
	
	print("player: %s, peer %s, current[%s], new[%s], id[%s], %s, fresh:%s | tick:%s | frame: %s" % [name, multiplayer.get_unique_id(), current_state.state_name, new_state.state_name, current_state_id, movement_input, is_fresh, tick, Engine.get_frames_drawn()])
	
	# if not the same state, change state
	if new_state.state_name != current_state.state_name:
		_movement_sm.change_state(current_state, new_state)

	_movement_sm.process_physics(delta, tick, is_fresh, Engine.get_frames_drawn())
	
func _determine_state(movement_input: Vector2, current_state):
	#var new_state : State = get_current_state()
	var new_state
	
	_force_update_is_on_floor()
	if not is_on_floor():
		# fall
		new_state = _fall_state
	else:
		# is on floor
		# TODO: should this be directly from _player_input??
		if _player_input.jump_input: #current_state.get_jump():
			# jump
			new_state = _jump_state
		elif movement_input != Vector2.ZERO:
			# move
			new_state = _move_state
		else:
			# idle
			new_state = _idle_state
	
	return new_state

func get_current_state() -> State:
	return get_state_from_id(current_state_id)

func set_current_state(new_state: State):
	if new_state:
		current_state_id = new_state.name

# TODO: refactor to something cleaner, this is just for debugging current synch problem
func get_state_from_id(id: String) -> State:
	if id && id != "":
		match id:
			"Idle":
				#print("Idle")
				return _idle_state
			"Move":
				#print("Move")
				return _move_state
			"Jump":
				#print("Jump")
				return _jump_state
			"Fall":
				#print("Fall")
				return _fall_state
	return null

				
# https://foxssake.github.io/netfox/netfox/tutorials/rollback-caveats/#characterbody-on-floor
func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity *= 0
	move_and_slide()
	velocity = old_velocity
