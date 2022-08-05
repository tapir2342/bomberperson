extends Node2D

var tile_size = 32
var inputs = {
	"player_right": Vector2.RIGHT,
	"player_left": Vector2.LEFT,
	"player_up": Vector2.UP,
	"player_down": Vector2.DOWN,
}

puppet var puppet_position = Vector2()


func _ready():
	position = position.snapped(Vector2.ONE * tile_size * int(rand_range(1, 10)))
	position += Vector2.ONE * tile_size / 2
	puppet_position = position
	pause_mode = Node.PAUSE_MODE_PROCESS


func _process(delta):
	if self.is_network_master():
		for dir in inputs.keys():
			if Input.is_action_pressed(dir):
				move(dir)

		rset("puppet_position", position)
	else:
		position = puppet_position


func move(dir):
	position += inputs[dir] * tile_size
