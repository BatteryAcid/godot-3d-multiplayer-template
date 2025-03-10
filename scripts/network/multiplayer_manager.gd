class_name MultiplayerManager
extends Node

# The bulk of this script is for the authority (host/server).

@export var _player_spawn_point: Node3D

var _multiplayer_scene = preload("res://scenes/player/player.tscn")
var _players_in_game: Dictionary = {}

func _ready():
	# NOTE: For client peers, this likely loaded (as part of the Game scene) 
	# before we have an active connection (peer). Therefore, don't rely on this
	# function for client-side network setup or authority checks.

	print("MultiplayerManager ready!")

	# This section is for the authority (host/server), so we don't check for authority
	# unless a peer has been established.
	if multiplayer.has_multiplayer_peer() && is_multiplayer_authority():
		# Leverage the peer connected signal to trigger the player spawn
		multiplayer.peer_connected.connect(_peer_connected)
		
		# Handle the disconnect signal here so we have access to what needs cleaned up in game.
		multiplayer.peer_disconnected.connect(_peer_disconnected)
		
		# We don't want to add a player to a dedicated server instance
		if NetworkManager.is_hosting_game && not OS.has_feature(NetworkManager.DEDICATED_SERVER_FEATURE_NAME):
			print("Adding Host player to game...")
			_add_player_to_game(1)

func _add_player_to_game(network_id: int):
	if is_multiplayer_authority():
		print("Adding player to game: %s" % network_id)
		
		if _players_in_game.get(network_id) == null:
			var player_to_add = _multiplayer_scene.instantiate()
			player_to_add.name = str(network_id)
			_ready_player(player_to_add)
			
			_players_in_game[network_id] = player_to_add
			_player_spawn_point.add_child(player_to_add)
		else:
			print("Warning! Attempted to add existing player to game: %s" % network_id)
	
func _remove_player_from_game(network_id: int):
	if is_multiplayer_authority():
		print("Removing player from game: %s" % network_id)
		if _players_in_game.has(network_id):
			var player_to_remove = _players_in_game[network_id]
			if player_to_remove:
				player_to_remove.queue_free()		
				_players_in_game.erase(network_id)

# Setup initial or reload saved player properties
func _ready_player(player: Player):
	if is_multiplayer_authority():
		player.position = Vector3(randi_range(-2, 2), 1, randi_range(-2, 2))

func _peer_connected(network_id: int):
	print("Peer connected: %s" % network_id)
	if is_multiplayer_authority():
		_add_player_to_game(network_id)
		
func _peer_disconnected(network_id: int):
	print("Peer disconnected: %s" % network_id)
	_remove_player_from_game(network_id)
