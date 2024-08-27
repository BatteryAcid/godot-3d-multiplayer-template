extends Node

# Source: https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines

@export var starting_state: State

var current_state: State

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init(parent: Player, move_component: Node, animation_player: AnimationPlayer) -> void:
	for child_state in get_children():
		child_state.parent = parent
		child_state.animation_player = animation_player
		child_state.move_component = move_component

	# NOTE: we have to manually set current_state and enter it here, to avoid 'node not found' issue
	# from RPC in change_state.
	current_state = starting_state
	current_state.enter()

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state

	print("change_state: [%s] on peer: %s: " % [new_state.name, multiplayer.get_unique_id()])
	current_state.enter()

	if is_multiplayer_authority():
		update_state_on_client.rpc(str(current_state.name))
	
# Pass through functions for the Player to call, handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_physics_client(delta: float):
	current_state.process_physics_client(delta)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)

@rpc("authority")
func update_state_on_client(change_to_state: String):
	print("update_state_on_client")
	for child_state in get_children():
		if child_state.name == change_to_state:
			# print("Changed to state %s" % child_state.name)
			change_state(child_state)
