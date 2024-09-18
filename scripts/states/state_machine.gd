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
	player.current_state.enter()

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: State) -> void:
	if player.current_state:
		#print("Exiting state: %s" % current_state.state_name)
		player.current_state.exit()

	player.current_state = new_state

	print("change_state: [%s] on peer: %s: " % [new_state.name, multiplayer.get_unique_id()])
	player.current_state.enter()

# Pass through functions for the Player to call, handling state changes as needed.
func process_physics(delta: float, tick, is_fresh: bool, current_frame) -> void:
	player.current_state.process_physics(delta, tick, is_fresh, current_frame)
