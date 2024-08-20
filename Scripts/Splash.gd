extends Control


func _ready():
	yield(get_tree().create_timer(0.1),"timeout")
	$AnimationPlayer.play("start")

func _input(event):
	if event.is_action_pressed("left_click"):
		_on_AnimationPlayer_animation_finished("start")


func _on_AnimationPlayer_animation_finished(_anim_name):
	global.change_scenes("res://Maps/TutorialFarm.tscn",2)
