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
	var coords := []

	for i in range(0, self.radius + 1):
		var xoff = int(origin.x + i)
		var yoff = int(origin.y)

		if _walls.get_cell(xoff, yoff) != -1:
			break

		if _rocks.get_cell(xoff, yoff) != -1:
			coords.append([xoff, yoff])
			break

		coords.append([xoff, yoff])

	# Go left
	for i in range(0, self.radius + 1):
		var xoff = int(origin.x - i)
		var yoff = int(origin.y)

		if _walls.get_cell(xoff, yoff) != -1:
			break

		if _rocks.get_cell(xoff, yoff) != -1:
			coords.append([xoff, yoff])
			break

		coords.append([xoff, yoff])

	# Go up
	for i in range(0, self.radius + 1):
		var xoff = int(origin.x)
		var yoff = int(origin.y - i)

		if _walls.get_cell(xoff, yoff) != -1:
			break

		if _rocks.get_cell(xoff, yoff) != -1:
			coords.append([xoff, yoff])
			break

		coords.append([xoff, yoff])

	# Go down
	for i in range(0, self.radius + 1):
		var xoff = int(origin.x)
		var yoff = int(origin.y + i)

		if _walls.get_cell(xoff, yoff) != -1:
			break

		if _rocks.get_cell(xoff, yoff) != -1:
			coords.append([xoff, yoff])
			break

		coords.append([xoff, yoff])

	return coords
