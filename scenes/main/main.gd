extends Node2D

const Player := preload("res://scenes/player/player.tscn")

var _spawnpoints := [
	Vector2(48, 48),
	Vector2(48, 432),
	Vector2(432, 48),
	Vector2(432, 560),
]


func _ready() -> void:
	randomize()
	Game.connect("started", self, "_on_game_started")

	var peer_mode := "Client"

	if Game.is_server():
		peer_mode = "Server"

	$CanvasLayer/Control/PeerMode.text = peer_mode


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "HTML5":
		get_tree().quit()


func _on_game_started() -> void:
	var i := 0
	for key in Game.players:
		var p = Game.players[key]
		var player = Player.instance()
		player.set_name(str(p.peer_id))
		player.set_network_master(p.peer_id)
		player.sprite_name = "res://sprites/players/%s.png" % p.avatar
		player.global_position = _spawnpoints[i]
		add_child(player)
		i += 1
