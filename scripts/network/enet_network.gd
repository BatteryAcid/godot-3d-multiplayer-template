extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

func create_server_peer():
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
	
func create_client_peer():
	var enet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	enet_network_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = enet_network_peer
