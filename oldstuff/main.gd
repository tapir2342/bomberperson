extends Node2D


const Player := preload("res://player.tscn")

export var _server := false

var _server_port := 2342

onready var _button_play_server : Button = $CanvasLayer/Control/PlayAsServer
onready var _button_play_client : Button = $CanvasLayer/Control/PlayAsClient

onready var _tree := get_tree()


func _ready() -> void:
	var peer = NetworkedMultiplayerENet.new()

	if _is_server():
		print("SERVER")
		$CanvasLayer/Control/PeerMode.text = "Server"
		peer.create_server(_server_port, 4)
	else:
		print("CLIENT")
		$CanvasLayer/Control/PeerMode.text = "Client"
		peer.create_client("127.0.0.1", _server_port)

	get_tree().network_peer = peer

	#rpc("pre_configure_game")





func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "HTML5":
		get_tree().quit()


func _is_server() -> bool:
	return "--server" in OS.get_cmdline_args() or  OS.has_feature("Server")
