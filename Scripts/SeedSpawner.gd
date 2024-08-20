extends Node2D

const SEED_RANDOM_POSITION = 5

export var levelAppear = 0
export var attachedSeedPath : NodePath
onready var attachedSeed = get_node_or_null(attachedSeedPath)

var seedNode = preload("res://Nodes/Fertilizer.tscn")
var tutorial = false

func _ready():
	if global.level < levelAppear:
		queue_free()
		attachedSeed.queue_free()
	if attachedSeed != null:
		attachedSeed.connect("destroyed", self, "start_creating", [], CONNECT_ONESHOT)

func set_attached_seed(newSeed):
	attachedSeed = newSeed
	attachedSeed.connect("destroyed", self, "start_creating", [], CONNECT_ONESHOT)

func start_creating():
	if $AnimationPlayer.is_playing():
		yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Spawn")

func create_seed():
	var newParent = get_parent()
	var newSeed = seedNode.instance()
	var randX = rand_range(-SEED_RANDOM_POSITION, SEED_RANDOM_POSITION)
	var randY = rand_range(-SEED_RANDOM_POSITION, SEED_RANDOM_POSITION)
	var randomOffset = Vector2(randX, randY).round()
	newSeed.global_position = $TrunkPos.global_position
	newSeed.set_collisions(false)
	var newPos = $LandPos.global_position + randomOffset
	newParent.call_deferred("add_child", newSeed)
	yield(get_tree(),"idle_frame")
	newSeed.throw(-25, newPos, 0.5)
	$AudioStreamPlayer2D.play(0.01)
	if !tutorial:
		set_attached_seed(newSeed)
