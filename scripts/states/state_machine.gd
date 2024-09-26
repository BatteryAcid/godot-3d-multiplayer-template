extends Node

# Based on: https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines
var player : Player

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init(parent: Player, move_component: Node, animation_player: AnimationPlayer) -> void:
	player = parent
	
	for child_state in get_children():
		child_state.parent = parent
		child_state.animation_player = animation_player
		child_state.move_component = move_component

	# Enter first state
	player.get_current_state().enter()

# Change to the new state by first calling any exit logic on the current state.
func change_state(current_state: State, new_state: State) -> void:
	if current_state: #player.get_current_state():
		print("Exiting state: %s" % current_state.state_name)
		current_state.exit()
		# player.get_current_state().exit()

	player.set_current_state(new_state)

	print("change_state: from [%s] to [%s] on peer: %s: " % [current_state.state_name, new_state.state_name, multiplayer.get_unique_id()])
	new_state.enter()
	# player.get_current_state().enter()

# Pass through functions for the Player to call, handling state changes as needed.
func process_physics(delta: float, tick, is_fresh: bool, current_frame) -> void:
	player.get_current_state().process_physics(delta, tick, is_fresh, current_frame)
