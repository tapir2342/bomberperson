extends Node

signal started

const SERVER_ADDRESS := "127.0.0.1"
const SERVER_PORT := 2342
const SERVER_MAX_CLIENTS := 4

onready var _tree := get_tree()

var players = {}

var game_started = false


func _ready():
	_tree.connect("network_peer_connected", self, "_on_network_peer_connected")
	_setup_network_peer()

	if not is_server():
		players[_tree.get_network_unique_id()] = {}


func _setup_network_peer() -> void:
	var peer = NetworkedMultiplayerENet.new()

	if is_server():
		peer.create_server(Game.SERVER_PORT, Game.SERVER_MAX_CLIENTS)
	else:
		peer.create_client(Game.SERVER_ADDRESS, Game.SERVER_PORT)

	_tree.network_peer = peer


func is_server() -> bool:
	return "--server" in OS.get_cmdline_args() or OS.has_feature("Server")


func _on_network_peer_connected(peer_id: int) -> void:
	print("PEER CONNECTED: %d" % peer_id)
	rpc_id(peer_id, "register_player")
	_maybe_start_game()


remote func register_player() -> void:
	var peer_id = _tree.get_rpc_sender_id()
	if peer_id != 1:
		players[peer_id] = {}
	_maybe_start_game()


func _maybe_start_game():
	if len(players) == 2 and not game_started:
		game_started = true
		emit_signal("started")
