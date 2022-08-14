extends Node2D

const Player := preload("res://scenes/player/player.tscn")

onready var _ui_waiting: Control = get_node("/root/Main/CanvasLayer/Waiting")

var _spawnpoints := [
	Vector2(48, 48),
	Vector2(48, 432),
	Vector2(432, 48),
	Vector2(432, 560),
]


func _ready() -> void:
	randomize()

	# warning-ignore:return_value_discarded
	Game.connect("started", self, "_on_game_started")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "HTML5":
		get_tree().quit()


func _on_game_started() -> void:
	_ui_waiting.visible = false

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
