extends Node2D

export var seedSpawnerPath : NodePath
onready var seedSpawner = get_node_or_null(seedSpawnerPath)
onready var cameraZoomPos = $CameraZoom



func _ready():
	$AnimationPlayer.play("Idle")

func inhale():
	$AnimationPlayer.play("RoarAnticipation")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Inhale")

func roar():
	$AnimationPlayer.play("RoarAnticipation")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Roar")

func idle():
	$AnimationPlayer.play("Idle")

func _on_Area2D_area_entered(area):
	var turnip = area.get_parent().get_parent()
	
	if turnip.name == "Fire":
		return
	
	#if turnip somehow enters the area again
	if turnip.queuedEaten:
		return
	else:
		turnip.queuedEaten = true
	
	yield(get_tree().create_timer(0.1), "timeout")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Chew")
	turnip.die()
	global.increase_turnip_counter(turnip.size)
	global.decrease_hunger(turnip.size * 10)
	global.increase_difficulty(turnip.size)
	#if seedSpawner != null:
		#seedSpawner.start_creating()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Chew":
		$AnimationPlayer.play("Idle")
