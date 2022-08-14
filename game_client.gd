class_name GameClient
extends Node

onready var _tree := self.get_tree()

var _peer: WebSocketClient


func _ready() -> void:
	_peer = _create_network_peer()
	_setup_network_peer()


func _process(_delta) -> void:
	_peer.poll()


func _create_network_peer() -> WebSocketClient:
	var server_address_port = "%s:%d" % [Game.SERVER_ADDRESS, Game.SERVER_PORT]
	print("Starting client (server address: %s)..." % server_address_port)
	var peer = WebSocketClient.new()
	peer.verify_ssl = Game.SERVER_USE_SSL

	var err = peer.connect_to_url(server_address_port, Game.CLIENT_PROTOCOLS, true)
	if err != OK:
		print("Client: Failed connect to server (server address: %s)", Game.SERVER_ADDRESS)
		self.set_process(false)
		# NOTE: Cannot get_tree().quit() on HTML5.
		return null

	return peer


func _setup_network_peer() -> void:
	# warning-ignore:return_value_discarded
	_peer.connect("connection_closed", self, "_on_connection_closed")

	# warning-ignore:return_value_discarded
	_peer.connect("connection_error", self, "_on_connection_error")

	# warning-ignore:return_value_discarded
	_peer.connect("connection_established", self, "_on_connection_established")

	_tree.network_peer = _peer


func _on_connection_closed(_was_clean_close: bool) -> void:
	print("CONNECTION CLOSED")


func _on_connection_error() -> void:
	print("CONNECTION ERROR")


func _on_connection_established(_protocol: String) -> void:
	print("CONNECTION ESTABLISHED")
