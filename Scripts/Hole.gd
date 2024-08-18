extends Node2D

export var newParentPath : NodePath
onready var newParent = get_node_or_null(newParentPath)

onready var timer = $Timer

var turnipNode = preload("res://Nodes/Turnip.tscn")

var opened = false

func _ready():
	open()

func create_turnip():
	close()
	if newParent != null:
		var turnip = turnipNode.instance()
		turnip.position = position
		newParent.call_deferred("add_child", turnip)
		timer.start()
		$AudioStreamPlayer.play()

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
