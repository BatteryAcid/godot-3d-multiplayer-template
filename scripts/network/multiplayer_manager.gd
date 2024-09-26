extends Node

@export var _player_spawn_point: Node3D

var _multiplayer_scene = preload("res://scenes/player/player.tscn")

var _players_in_game: Dictionary = {}

func _ready():
	# need this to allow time for the callbacks to be established
	await get_tree().process_frame
	
	if NetworkManager.is_hosting_game:
		print("Network lifecicle setup")
		multiplayer.peer_connected.connect(_client_connected)
		multiplayer.peer_disconnected.connect(_client_disconnected)
		
		# NOTE: can comment this out if you want to test locally as a dedicated server (no client)
		if not OS.has_feature("dedicated_server"):
			_add_player_to_game(1)
	
	NetworkManager.hide_loading()

func _add_player_to_game(network_id: int):
	print("Adding player to game: %s" % network_id)

	var player_to_add = _multiplayer_scene.instantiate()
	player_to_add.name = str(network_id)
	_ready_player(player_to_add)
	
	_players_in_game[network_id] = player_to_add
	_player_spawn_point.add_child(player_to_add)
	
func _remove_player_from_game(network_id: int):
	print("Removing player from game: %s" % network_id)
	if _players_in_game.has(network_id):
		var player_to_remove = _players_in_game[network_id]
		if player_to_remove:
			player_to_remove.queue_free()		
			_players_in_game.erase(network_id)

func _ready_player(player: Player):
	player.position = Vector3(randi_range(-2, 2), 1, randi_range(-2, 2))

# Connection lifecycle
func _client_connected(network_id: int):
	print("Client connected %s" % network_id)
	_add_player_to_game(network_id)

func _client_disconnected(network_id: int):
	print("Client disconnected %s" % network_id)
	_remove_player_from_game(network_id)
