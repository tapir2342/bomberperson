extends Node2D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "HTML5":
		get_tree().quit()
