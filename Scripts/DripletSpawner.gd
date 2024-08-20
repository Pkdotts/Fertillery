extends Area2D

export var newParentPath : NodePath
var dripletNode = preload("res://Nodes/Driplet.tscn")

export var spawning = true
export var dripDelay = 5.0

onready var newParent = get_node_or_null(newParentPath)



func _ready():
	set_drip_timer(dripDelay)
	if spawning:
		$Timer.start()

func set_drip_timer(time):
	$Timer.wait_time = time

func set_spawning(enabled):
	spawning = enabled
	if spawning:
		$Timer.start()
		spawn_driplet()
	else:
		$Timer.stop()

func get_random_position():
	var size = $CollisionShape2D.shape.extents * 2 * self.transform.get_scale()
	var randX = $CollisionShape2D.global_position.x + rand_range(-size.x/2, size.x/2)
	var randY = $CollisionShape2D.global_position.y + rand_range(-size.y/2, size.y/2)
	
	return Vector2(randX, randY)

func spawn_driplet():
	if global.dripCount < global.maxDripCount and newParent != null:
		var driplet = dripletNode.instance()
		driplet.position = get_random_position().round()
		driplet.hide()
		newParent.call_deferred("add_child", driplet)
		yield(get_tree(), "idle_frame")
		driplet.spawn()
		driplet.show()

func start_timer():
	$Timer.start()

func stop_timer():
	$Timer.stop()

func _on_Timer_timeout():
	spawn_driplet()
