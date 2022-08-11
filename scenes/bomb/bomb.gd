class_name Bomb
extends Node2D

export(int, 1, 9) var radius := 2

onready var _sprite: Sprite = $Sprite
onready var _timer: Timer = $Timer
onready var _audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var _rocks: TileMap = get_node("/root/Main/World/Level1/Rocks")
onready var _walls: TileMap = get_node("/root/Main/World/Level1/Walls")
onready var _explosions: TileMap = get_node("/root/Main/World/Explosions")

var from_player


func _ready():
	_timer.connect("timeout", self, "explode")


func explode():
	_audio_player.play()
	_sprite.visible = false

	overlay_explosions()
	remove_rocks()

	self.visible = false


func overlay_explosions() -> void:
	var pos := _explosions.world_to_map(_explosions.to_local(self.global_position))

	for s in spread(pos):
		_explosions.set_cell(s[0], s[1], 0)

	yield(get_tree().create_timer(0.3), "timeout")

	for s in spread(pos):
		_explosions.set_cell(s[0], s[1], -1)


func remove_rocks() -> void:
	var pos := _rocks.world_to_map(_rocks.to_local(self.global_position))

	for s in spread(pos):
		_rocks.set_cell(s[0], s[1], -1)


func spread(origin: Vector2) -> Array:
	var cells := []
	var directions := [
		{x = +1, y = 0},
		{x = -1, y = 0},
		{x = 0, y = +1},
		{x = 0, y = -1},
	]

	for direction in directions:
		for i in range(0, self.radius + 1):
			var xoff = int(origin.x + i * direction.x)
			var yoff = int(origin.y + i * direction.y)

			if _walls.get_cell(xoff, yoff) != -1:
				break

			if _rocks.get_cell(xoff, yoff) != -1:
				cells.append([xoff, yoff])
				break

			cells.append([xoff, yoff])

	return cells
