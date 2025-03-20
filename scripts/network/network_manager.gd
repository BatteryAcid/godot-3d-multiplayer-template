extends Node

# Autoloader (singleton) to manage network selection and setup
# IMPORTANT: 
# Variables like is_hosting_game must be reset upon exiting to main menu after a game has been played.

const GAME_SCENE = "res://scenes/game.tscn"
const MAIN_MENU_SCENE = "res://scenes/menus/main_menu.tscn"
const LOCALHOST = "127.0.0.1"
const DEDICATED_SERVER_FEATURE_NAME = "dedicated_server"

enum AvailableNetworks {ENET, NORAY}

var _available_networks: Dictionary = {
	0: {"scene":"res://scenes/network/enet_network.tscn", "menu":"res://scenes/menus/enet_menu.tscn"},
	1: {"scene":"res://scenes/network/noray_network.tscn", "menu":"res://scenes/menus/noray_menu.tscn"}
}

# Default to ENET
var selected_network: AvailableNetworks = AvailableNetworks.ENET
var selected_network_configuration: Dictionary = _available_networks[0]

var _loading_scene = preload("res://scenes/loading.tscn")
var _active_loading_scene
var active_network_node
var is_hosting_game = false
var active_host_ip = ""
var active_game_id = ""

func host_game(network_connection_configs: NetworkConnectionConfigs):
	print("Host game")
	if not OS.has_feature(DEDICATED_SERVER_FEATURE_NAME):
		show_loading()
	
	# print("Selected network scene: %s" % selected_network_configuration.scene)
	
	# Keep these before the network scene is instantiated, to allow its _ready function to correctly read these properties.
	is_hosting_game = true
	active_host_ip = network_connection_configs.host_ip
	
	# We add the scene representing the selected network to the current tree
	# so that we can access the multiplayer APIs
	var network_scene = load(selected_network_configuration.scene)
	active_network_node = network_scene.instantiate()
	add_child(active_network_node)
	
	# Need to await here to avoid loading game scene to early
	await active_network_node.create_server_peer(network_connection_configs)
	
	_load_game_scene()

func join_game(network_connection_configs: NetworkConnectionConfigs):
	print("Join game, host_ip: %s:%s, game_id: %s" % [network_connection_configs.host_ip, network_connection_configs.host_port, network_connection_configs.game_id])
	show_loading()
	
	# Client peers should load the game scene immediately, so that once the connection is made,
	# we don't have to wait for it to load. 
	_load_game_scene()
	
	var network_scene = load(selected_network_configuration.scene)
	active_network_node = network_scene.instantiate()
	add_child(active_network_node)
	
	# Connect client-side lifecycle signals
	active_network_node.network_server_disconnected.connect(disconnect_from_game)
	
	active_network_node.create_client_peer(network_connection_configs)
	
func set_selected_network(network_selected: AvailableNetworks):
	print("Network selection updated: %s" % network_selected)
	selected_network = network_selected
	selected_network_configuration = _available_networks[network_selected]

# Use this to kill the network connection and clean up for return to main menu
func disconnect_from_game():
	_load_main_menu_scene()
	
	NetworkTime.stop() # Stops the network type synchronizer from spamming ping RPCs after disconnect
	multiplayer.multiplayer_peer = null # Disconnect peer
	
	# Remove any child networks nodes
	for child in get_children():
		print("Removing child network node")
		child.queue_free()
	
	# Reset properties
	reset_selected_network()
	reset_network_properties()
	
	# Make sure player has mouse access to select menu options
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Hit this in case we disconnected during loading screen
	hide_loading()

func reset_network_properties():
	is_hosting_game = false
	active_host_ip = ""
	active_game_id = ""
	
	active_network_node.queue_free()
	active_network_node = null

func reset_selected_network():
	selected_network = AvailableNetworks.ENET
	selected_network_configuration = _available_networks[0]

func _load_game_scene():
	print("NetworkManager: Loading game scene...")
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))

func _load_main_menu_scene():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func show_loading():
	print("Show loading")
	_active_loading_scene = _loading_scene.instantiate()
	get_tree().root.add_child(_active_loading_scene)
	
func hide_loading():
	print("Hide loading")
	if _active_loading_scene != null:
		get_tree().root.remove_child(_active_loading_scene)
		_active_loading_scene.queue_free()
