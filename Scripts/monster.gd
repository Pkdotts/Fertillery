extends Node2D

export var newParentPath : NodePath

var fertilizerNode = preload("res://Nodes/Fertilizer.tscn")

const FERTILIZER_RANDOM_POSITION = 50

onready var newParent = get_node_or_null(newParentPath)
onready var fertilizerPositions = $FertilizerPositions

func _ready():
	pass # Replace with function body.

func create_fertilizers(amount):
	if newParent != null:
		if amount > 3:
			amount = 3
		for i in amount:
			var fertilizer = fertilizerNode.instance()
			var randX = rand_range(-FERTILIZER_RANDOM_POSITION, FERTILIZER_RANDOM_POSITION)
			var randY = rand_range(-FERTILIZER_RANDOM_POSITION, FERTILIZER_RANDOM_POSITION)
			var randomOffset = Vector2(randX, randY).round()
			fertilizer.global_position = fertilizerPositions.get_child(i).global_position + randomOffset
			newParent.call_deferred("add_child", fertilizer)

func _on_Area2D_area_entered(area):
	var turnip = area.get_parent().get_parent()
	turnip.die()
	global.increase_turnip_counter(turnip.size)
	create_fertilizers(1)
