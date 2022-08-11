class_name Player
extends KinematicBody2D

const Bomb := preload("res://scenes/bomb/bomb.tscn")

onready var _sprite: Sprite = $Sprite

var inputs := {
	"player_right": Vector2.RIGHT,
	"player_left": Vector2.LEFT,
	"player_up": Vector2.UP,
	"player_down": Vector2.DOWN,
}
var bomb_index := 0
var velocity := Vector2()
var speed := 1

puppet var sprite_name: String
puppet var puppet_position = Vector2()


func _ready():
	self._sprite.texture = load(self.sprite_name)

	#position = position.snapped(Vector2.ONE * Game.tile_size)
	#position += Vector2.ONE * Game.tile_size / 2

	puppet_position = global_position


func _unhandled_input(event):
	if event.is_action_pressed("player_plant_bomb") and self.is_network_master():
		bomb_index += 1
		var nid = get_tree().get_network_unique_id()
		var name = "bomb_%d_%d" % [nid, bomb_index]
		rpc("plant_bomb", name, self.global_position, self)

	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			move(dir)


func _physics_process(_delta):
	if self.is_network_master():
		rset("puppet_position", position)
	else:
		position = puppet_position


func move(dir):
	self.velocity = inputs[dir] * speed * (Game.tile_size / 1)
	self.move_and_collide(self.velocity)


remotesync func plant_bomb(name: String, position: Vector2, owner: Player) -> void:
	var bomb := Bomb.instance()
	bomb.global_position = position
	bomb.from_player = owner
	bomb.set_name(name)
	bomb.set_as_toplevel(true)
	add_child(bomb)
