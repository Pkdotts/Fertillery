extends Control

signal transition_finished

onready var animPlayer = $AnimationPlayer

func fadein():
	animPlayer.play("FadeIn")

func fadeout():
	animPlayer.play("FadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transition_finished")
