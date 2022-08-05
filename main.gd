extends Node2D

const Player := preload("res://player.tscn")


func _ready() -> void:
	Game.connect("started", self, "_on_game_started")

	if Game.is_server():
		print("Server")
		$CanvasLayer/Control/PeerMode.text = "Server"
	else:
		print("Client")
		$CanvasLayer/Control/PeerMode.text = "Client"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "HTML5":
		get_tree().quit()


func _on_game_started() -> void:
	print("GAME STARTED!!1!")
	print(Game.players)

	for p in Game.players:
		var player = Player.instance()
		player.set_name(str(p))
		player.set_network_master(p)
		add_child(player)
