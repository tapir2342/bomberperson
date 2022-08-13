extends Node

signal started
signal player_died(peer_id)

# Local:
#const SERVER_ADDRESS := "127.0.0.1"

# IPv4:
# ​ WARNING: Unable to change IPv4 address mapping over IPv6 option
#​    at: set_ipv6_only_enabled (drivers/unix/net_socket_posix.cpp:663) - Unable to change IPv4 address mapping over IPv6 option
#​    at: set_broadcasting_enabled (drivers/unix/net_socket_posix.cpp:630) - Unable to change broadcast setting
#​    at: poll (modules/enet/networked_multiplayer_enet.cpp:228) - Method failed.
#​    ...
#const SERVER_ADDRESS := "51.15.71.106"

# IPv6:
const SERVER_ADDRESS := "2001:bc8:1820:121c::1"

const SERVER_PORT := 23420
const SERVER_MAX_CLIENTS := 4

onready var _tree := get_tree()

puppetsync var players = {}

var tile_size := 32
var game_started = false

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


func _setup_network_peer() -> void:
	var peer = NetworkedMultiplayerENet.new()

	if is_server():
		print("Creating server (port: %d, max clients: %d)..." % [SERVER_PORT, SERVER_MAX_CLIENTS])
		peer.create_server(Game.SERVER_PORT, Game.SERVER_MAX_CLIENTS)
	else:
		print("Creating client (server address: %s, port: %d)..." % [SERVER_ADDRESS, SERVER_PORT])
		peer.create_client(Game.SERVER_ADDRESS, Game.SERVER_PORT)

	_tree.network_peer = peer


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
