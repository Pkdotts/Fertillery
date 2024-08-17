extends Node2D

var maxDistance = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	var playerDirectionToMouse = global.player.position.direction_to(get_global_mouse_position())
	var diff = get_global_mouse_position() - global.player.position
	var newPosition = get_global_mouse_position()
	position = newPosition
	
	

func _input(event):
	if event.is_action_pressed("left_click") and global.dripletsFollowing.size() > 0:
		global.player.throw_driplet(position)
