extends Node

signal started
signal player_died(peer_id)

#const SERVER_ADDRESS := "127.0.0.1"
#const SERVER_ADDRESS := "51.15.71.106"
#const SERVER_ADDRESS := "2001:bc8:1820:121c::1"

#const SERVER_DOMAIN := "127.0.0.1"
const SERVER_DOMAIN := "bomberperson.tapir.lol"
const SERVER_ADDRESS := "wss://%s" % SERVER_DOMAIN
const SERVER_PROTOCOLS := PoolStringArray(["ludus"])
const SERVER_PORT := 23420
const SERVER_MAX_CLIENTS := 4

const CLIENT_PROTOCOLS := SERVER_PROTOCOLS

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
]


func _ready():
	randomize()

	#_tree.connect("network_peer_connected", self, "_on_network_peer_connected")
	_tree.connect("connected_to_server", self, "_on_connected_to_server")
	_tree.connect("connection_failed", self, "_on_connection_failed")
	_setup_network_peer()

	#var crypto := Crypto.new()
	#var key := crypto.generate_rsa(4096)
	#var cert := crypto.generate_self_signed_certificate(key, "CN=%s,O=A Game Company,C=IT" % SERVER_DOMAIN)


# NOTE: Only needed because this has been changed from NetworkedMultiplayerENet
# to using WebSocketServer & WebSocketClient. Will be disabled on clients when
# the server connection fails.
func _process(_delta) -> void:
	if not _peer:
		return

	_peer.poll()
	#if is_server():
	#	if _peer.is_listening():
	#		_peer.poll()
	#else:
	#	_peer.poll()


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
		_peer = _create_server_peer()
	else:
		_peer = _create_client_peer()

	_tree.network_peer = _peer


func _create_server_peer() -> WebSocketServer:
	#print("Generating  server certificates...")
	#var crypto := Crypto.new()
	#var key := crypto.generate_rsa(4096)
	#var cert := crypto.generate_self_signed_certificate(key, "CN=%s,O=A Game Company,C=IT" % SERVER_DOMAIN)

	print("Starting server (port: %d)..." % SERVER_PORT)
	var peer = WebSocketServer.new()
	peer.private_key = load("res://server.key")
	peer.ssl_certificate = load("res://server.crt")
	peer.handshake_timeout = 10.0

	var err = peer.listen(SERVER_PORT, SERVER_PROTOCOLS, true)
	if err != OK:
		print("Server: Failed to listen on port %d. Exiting.", SERVER_PORT)
		_tree.quit()
		return null

	return peer


func _create_client_peer() -> WebSocketClient:
	var server_address_port = "%s:%d" % [SERVER_ADDRESS, SERVER_PORT]
	print("Starting client (server address: %s)..." % server_address_port)
	var peer = WebSocketClient.new()
	peer.verify_ssl = false

	var err = peer.connect_to_url(server_address_port, CLIENT_PROTOCOLS, true)
	if err != OK:
		print("Client: Failed connect to server (server address: %s)", SERVER_ADDRESS)
		set_process(false)
		# NOTE: Cannot get_tree().quit() on HTML5.
		return null

	return peer


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
