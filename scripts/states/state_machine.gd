extends Node

# Source: https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines

@export var starting_state: State
@export var _player_input_move_component : Node

var current_state: State

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init(parent: Player, animations: AnimatedSprite2D) -> void: #, move_component
	for child in get_children():
		child.parent = parent
		child.animations = animations
		child.move_component = _player_input_move_component #move_component

	# Initialize to the default state
	change_state(starting_state)

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	
# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
