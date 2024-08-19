extends Area2D

export var newParentPath : NodePath
export var turnipParentPath : NodePath
export var seedSpawnerPath : NodePath
export var enabled = false
export var wait_time = 30

var holeNode = preload("res://Nodes/Hole.tscn")

var attachedHole = null

onready var newParent = get_node_or_null(newParentPath)
onready var seedSpawner = get_node_or_null(seedSpawnerPath)

func _ready():
	if enabled:
		spawn_hole()

func get_random_position():
	var size = $CollisionShape2D.shape.extents * 2 * self.transform.get_scale()
	var randX = $CollisionShape2D.global_position.x + rand_range(-size.x/2, size.x/2)
	var randY = $CollisionShape2D.global_position.y + rand_range(-size.y/2, size.y/2)
	
	return Vector2(randX, randY)

func set_enable(value):
	enabled = value

func spawn_hole():
	if attachedHole == null and enabled:
		var hole = holeNode.instance()
		hole.newParentPath = turnipParentPath
		hole.position = get_random_position().round()
		newParent.call_deferred("add_child", hole)
		attachedHole = hole
		hole.set_seed_spawner(seedSpawner)
		hole.set_wait_time(wait_time)

func erase_hole():
	if attachedHole != null:
		attachedHole.queue_free()
		attachedHole = null
