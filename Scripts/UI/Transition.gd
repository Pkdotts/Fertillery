extends Control

signal transition_finished

onready var animPlayer = $AnimationPlayer

func fadein(speed = 1):
	animPlayer.playback_speed = speed
	animPlayer.play("FadeIn")

func fadeout(speed = 1):
	animPlayer.playback_speed = speed
	animPlayer.play("FadeOut")

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("transition_finished")
