extends Node

signal started

const SERVER_ADDRESS := "127.0.0.1"
const SERVER_PORT := 2342
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
	_setup_network_peer()


func _setup_network_peer() -> void:
	var peer = NetworkedMultiplayerENet.new()

	if is_server():
		peer.create_server(Game.SERVER_PORT, Game.SERVER_MAX_CLIENTS)
	else:
		peer.create_client(Game.SERVER_ADDRESS, Game.SERVER_PORT)

	_tree.network_peer = peer


func is_server() -> bool:
	return "--server" in OS.get_cmdline_args() or OS.has_feature("Server")


func _on_connected_to_server():
	rpc_id(1, "register_player")


master func register_player() -> void:
	var peer_id = _tree.get_rpc_sender_id()
	players[peer_id] = {
		peer_id = peer_id,
		avatar = random_avatar(),
	}
	rset("players", players)
	rpc("maybe_start_game")


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