extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	position = get_global_mouse_position()

func _input(event):
	if event.is_action_pressed("left_click") and global.teenipsFollowing.size() > 0:
		global.player.throw_teenip(position)
