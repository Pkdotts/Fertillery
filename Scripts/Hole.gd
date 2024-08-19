extends Node2D

signal created_turnip

export var newParentPath : NodePath
onready var newParent = get_node_or_null(newParentPath)

export var cutscenePath : NodePath
onready var cutscene = get_node_or_null(cutscenePath)

export var wait_time = 0

onready var timer = $Timer

var turnipNode = preload("res://Nodes/Turnip.tscn")

var opened = false

func _ready():
	open()
	if wait_time != 0:
		$Timer.wait_time = wait_time

func create_turnip():
	close()
	if newParent != null:
		var turnip = turnipNode.instance()
		turnip.position = position
		newParent.call_deferred("add_child", turnip)
		timer.start()
		$AudioStreamPlayer.play()
		if cutscene != null:
			turnip.set_tutorial_turnip(cutscene)
			cutscene = null
		emit_signal("created_turnip")

func close():
	opened = false
	$AnimationPlayer.play("Close")

func open():
	opened = true
	$AnimationPlayer.play("Open")

func _on_Area2D_area_entered(area):
	var parent = area.get_parent().get_parent()
	if opened and parent.get("state") != null and (parent.state != parent.States.HELD and parent.state != parent.States.MIDAIR):
		parent.die()
		$AnimationPlayer.play("GrowSprout")

func _on_Absorber_area_entered(area):
	var parent = area.get_parent().get_parent()
	if $AnimationPlayer.current_animation == "GrowSprout":
		parent.die()
		close()
		create_turnip()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "GrowSprout":
		close()
		create_turnip()


func _on_Timer_timeout():
	open()
