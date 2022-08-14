class_name GameServer
extends Node

onready var _tree := self.get_tree()

var _peer: WebSocketServer


func _ready() -> void:
	_peer = _create_network_peer()
	_setup_network_peer()


func _process(_delta) -> void:
	_peer.poll()


func _create_network_peer() -> WebSocketServer:
	var peer = WebSocketServer.new()
	if Game.SERVER_USE_SSL:
		peer.private_key = load("res://private.key")
		peer.ssl_certificate = load("res://certificate.crt")
		peer.handshake_timeout = 10.0

	print("Server: Listening on port %d..." % Game.SERVER_PORT)
	var err = peer.listen(Game.SERVER_PORT, Game.SERVER_PROTOCOLS, true)
	if err != OK:
		print("Server: Failed to listen on port %d. Exiting.", Game.SERVER_PORT)
		_tree.quit()
		return null

	return peer


func _setup_network_peer() -> void:
	# warning-ignore:return_value_discarded
	_peer.connect("peer_connected", self, "_on_peer_connected")

	# FIXME: Why don't these work?

	# warning-ignore:return_value_discarded
	#_peer.connect("client_close_request", self, "_on_client_close_request")

	# warning-ignore:return_value_discarded
	#_peer.connect("client_connected", self, "_on_client_connected")

	# warning-ignore:return_value_discarded
	#_peer.connect("client_disconnected", self, "_on_client_disconnected")

	_tree.network_peer = _peer


func _on_client_close_request(_id: int, _code: int, _reason: String) -> void:
	pass


func _on_peer_connected(id: int) -> void:
#func _on_client_connected(id: int, _protocol: String) -> void:
	print("CLIENT_CONNECTED")
	Game.players[id] = {
		peer_id = id,
		avatar = Game.random_avatar(),
		alive = true,
	}
	Game.rset("players", Game.players)
	Game.rpc("maybe_start_game")


func _on_client_disconnected(id: int, _was_clean_close: bool) -> void:
	if Game.players.has(id):
		Game.players.erase(id)
