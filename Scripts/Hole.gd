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
	visible = false

func open():
	opened = true
	visible = true

func _on_Area2D_area_entered(area):
	var fertilizer = area.get_parent().get_parent()
	if fertilizer.get("state") != null and fertilizer.state != fertilizer.States.HELD:
		fertilizer.die()
		create_turnip()
	

func _on_Timer_timeout():
	open()
