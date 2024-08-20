extends Node2D

signal ate

var cutscenePath : NodePath

onready var cutscene

func _ready():
	global.tutorial = true

func _on_Area2D_area_entered(area):
	yield(get_tree().create_timer(0.05), "timeout")
	var turnip = area.get_parent().get_parent()
	turnip.die()
	$AudioStreamPlayer.play()
	$AnimationPlayer.play("Yummers")
	emit_signal("ate")

func die():
	$AnimationPlayer.play("RIP BOZO")
	yield($AnimationPlayer,"animation_finished")
	queue_free()
