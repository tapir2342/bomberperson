extends Node

signal started
signal player_died(peer_id)

#const SERVER_ADDRESS := "127.0.0.1"
#const SERVER_ADDRESS := "51.15.71.106"
#const SERVER_ADDRESS := "2001:bc8:1820:121c::1"

const SERVER_ADDRESS := "ws://51.15.71.106"

const SERVER_PORT := 23420
const SERVER_MAX_CLIENTS := 4

onready var _tree := get_tree()

puppetsync var players = {}

var tile_size := 32
var game_started = false

var _peer
var _avatars = [
	"gorilla",
	"crocodile",
	"cow",
	"dog",
	"duck",
]


func _ready():
	randomize()

	#_tree.connect("network_peer_connected", self, "_on_network_peer_connected")
	_tree.connect("connected_to_server", self, "_on_connected_to_server")
	_tree.connect("connection_failed", self, "_on_connection_failed")
	_setup_network_peer()


# NOTE: Only needed because this has been changed from NetworkedMultiplayerENet
# to using WebSocketServer & WebSocketClient. Will be disabled on clients when
# the server connection fails.
func _process(_delta) -> void:
	if is_server():
		if _peer.is_listening():
			_peer.poll()
	else:
		_peer.poll()


# NetworkedMultiplayerENet: Not supported on HTML5.
# ​ WARNING: Unable to change IPv4 address mapping over IPv6 option
#​    at: set_ipv6_only_enabled (drivers/unix/net_socket_posix.cpp:663) - Unable to change IPv4 address mapping over IPv6 option
#​    at: set_broadcasting_enabled (drivers/unix/net_socket_posix.cpp:630) - Unable to change broadcast setting
#​    at: poll (modules/enet/networked_multiplayer_enet.cpp:228) - Method failed.
#​    ...
#func _setup_network_peer() -> void:
#	var peer = NetworkedMultiplayerENet.new()
#
#	if is_server():
#		print("Creating server (port: %d, max clients: %d)..." % [SERVER_PORT, SERVER_MAX_CLIENTS])
#		peer.create_server(Game.SERVER_PORT, Game.SERVER_MAX_CLIENTS)
#	else:
#		print("Creating client (server address: %s, port: %d)..." % [SERVER_ADDRESS, SERVER_PORT])
#		peer.create_client(Game.SERVER_ADDRESS, Game.SERVER_PORT)
#
#	_tree.network_peer = peer
func _setup_network_peer() -> void:
	if is_server():
		print("Starting server (port: %d)..." % SERVER_PORT)
		_peer = WebSocketServer.new()
		# 1) port
		# 2) protocols: []
		# 3) gd_map_api: The server will behave like a network peer for the
		# MultiplayerAPI, connections from non-Godot clients will not work, and
		# data_received will not be emitted.
		var err = _peer.listen(SERVER_PORT, PoolStringArray(), true)
		if err != OK:
			print("Server: Failed to listen on port %d. Exiting.", SERVER_PORT)
			_tree.quit()
	else:
		var server_address_port = "%s:%d" % [SERVER_ADDRESS, SERVER_PORT]
		print("Starting client (server address: %s)..." % server_address_port)
		_peer = WebSocketClient.new()
		# See above. NOTE: Also needs gd_mp_api = true.
		var err = _peer.connect_to_url(server_address_port, PoolStringArray(), true)
		if err != OK:
			print("Client: Failed connect to server (server address: %s)", SERVER_ADDRESS)
			set_process(false)
			# NOTE: Cannot get_tree().quit() on HTML5.

	_tree.network_peer = _peer


func is_server() -> bool:
	return "--server" in OS.get_cmdline_args() or OS.has_feature("Server")


# Server & all clients.
func _on_network_peer_connected(id: int) -> void:
	if not _tree.get_network_unique_id() != 1:
		return

	print("Server: Client #%d connected!" % id)


# Only on clients.
func _on_connected_to_server() -> void:
	rpc_id(1, "register_player")

# Only on clients.
func _on_connection_failed() -> void:
	print("Client %d: Failed to connect to server (server address: %s, port: %d)" % [_tree.get_network_unique_id(), SERVER_ADDRESS, SERVER_PORT])


master func register_player() -> void:
	var peer_id = _tree.get_rpc_sender_id()
	players[peer_id] = {
		peer_id = peer_id,
		avatar = random_avatar(),
		alive = true,
	}
	rset("players", players)
	rpc("maybe_start_game")


master func register_player_death() -> void:
	var peer_id = _tree.get_rpc_sender_id()
	if not Game.players.has(peer_id):
		return

	Game.players[peer_id].alive = false
	print(Game.players)


remotesync func maybe_start_game():
	print("Peer: %d - Players: %s" % [_tree.get_network_unique_id(), players])
	if len(players) == 2 and not game_started:
		game_started = true
		emit_signal("started")


func random_avatar() -> String:
	var random_index = randi() % len(_avatars)
	var random_avatar = _avatars[random_index]
	_avatars.remove(random_index)
	return random_avatar
