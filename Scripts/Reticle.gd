extends Node2D

var mode = 0


func _ready():
	set_mode(2)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	var newPosition = get_global_mouse_position()
	global_position = newPosition

func _input(event):
	if event.is_action_pressed("left_click"):
		if global.player != null and mode == 0 and visible:
			var throwPosition = global_position + global.currentCamera.get_camera_screen_center() - global.winDim/2
			global.player.throw(throwPosition)
			print(throwPosition)

func set_mode(modeNum):
	mode = modeNum
	match mode:
		0:
			$Sprite.show()
			$Sprite2.hide()
		1:
			$Sprite.hide()
			$Sprite2.show()
		2:
			$Sprite.hide()
			$Sprite2.hide()

func play_sfx():
	$AudioStreamPlayer.play()
