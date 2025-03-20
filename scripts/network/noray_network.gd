extends Node

signal network_server_disconnected

var _port = 8890
var _current_host_oid = ""

func _ready():
	print("Noray network ready!")
	if NetworkManager.is_hosting_game:
		setup_host_noray_connection_signals()
	else:
		setup_client_noray_connection_signals()

# Hosting Noray - entry point
func create_server_peer(network_connection_configs: NetworkConnectionConfigs):
	print("Create Noray server peer")
	await _register_with_noray(network_connection_configs.host_ip)
	_start_noray_host()
	
# Joining Noray as client - entry point
func create_client_peer(network_connection_configs: NetworkConnectionConfigs):
	print("create Noray client peer")
	
	# Stash the game id (oid)
	_current_host_oid = network_connection_configs.game_id
	await _register_with_noray(network_connection_configs.host_ip)
	
	setup_client_enet_connection_signals()
	
	Noray.connect_nat(network_connection_configs.game_id)


func _register_with_noray(host_ip: String):
	print("Register with Noray hosted at: %s" % host_ip)
	var err = OK
	
	# connect to Noray
	err = await Noray.connect_to_host(host_ip, _port)
	if err != OK:
		print("Failed to connect to Noray for registration at %s:%s" % [host_ip, _port, err])
		return err
		
	# Register host
	Noray.register_host()
	await Noray.on_pid
	
	# Capture game_id to display on host-peer for sharing with others
	print("Noray oid/gameId: %s" % Noray.oid)
	NetworkManager.active_game_id = Noray.oid
	
	# Register remove address
	err = await Noray.register_remote()
	if err != OK:
		print("Failed to register remote %s" % err)
		return err
	
	print("Finished Noray registration")

func _start_noray_host():
	print("Starting Noray host")
	var err = OK
	
	var noray_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	err = noray_network_peer.create_server(Noray.local_port)
	multiplayer.multiplayer_peer = noray_network_peer
	
	if err != OK:
		print("Failed to listen on port %s with error: %s" % [Noray.local_port, err])


func _handle_noray_client_connect(address: String, port: int) -> Error:
	print("Noray host handle connect: %s:%s" % [address, port])
	var peer = multiplayer.multiplayer_peer as ENetMultiplayerPeer
	var err = await PacketHandshake.over_enet(peer.host, address, port)
	
	if err != OK:
		print("Noray packet handshake failed %s" % err)
		return err
	
	return OK


func _handle_nat_connect(address: String, port: int) -> Error:
	print("Attempting to connect client via NAT: %s:%s" % [address, port])
	var err = await _handle_connect(address, port)
	if err != OK:
		print("NAT connection failed from client, trying Relay instead...")
		Noray.connect_relay(_current_host_oid)
		return OK
	else:
		print("NAT punchthrough successful!")
	return err
	
func _handle_relay_connect(address: String, port: int) -> Error:
	print("Attempting to connect client via Relay: %s:%s" % [address, port])
	return await _handle_connect(address, port)

func _handle_connect(address: String, port: int) -> Error:
	print("Client handle connect to %s:%s, Noray.localport: %s" % [address, port, Noray.local_port])
	
	# Do a handshake
	var udp = PacketPeerUDP.new()
	udp.bind(Noray.local_port)
	udp.set_dest_address(address, port)
	
	var err = await PacketHandshake.over_packet_peer(udp, 8)
	udp.close()
	
	if err != OK:
		print("Client packet handshake failed %s" % err)
		return err
		
	# Connect to host
	var peer = ENetMultiplayerPeer.new()
	err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
	
	if err != OK:
		print("Create client failed %s" % err)
		return err
		
	multiplayer.multiplayer_peer = peer
	return OK


# Noray connection signals
func setup_host_noray_connection_signals():
	Noray.on_connect_nat.connect(_handle_noray_client_connect)
	Noray.on_connect_relay.connect(_handle_noray_client_connect)

func setup_client_noray_connection_signals():
	Noray.on_connect_nat.connect(_handle_nat_connect)
	Noray.on_connect_relay.connect(_handle_relay_connect)

# Client signals 
func setup_client_enet_connection_signals():
	multiplayer.server_disconnected.connect(_noray_server_disconnected)

func _noray_server_disconnected():
	print("Noray server disconnected")
	network_server_disconnected.emit()
