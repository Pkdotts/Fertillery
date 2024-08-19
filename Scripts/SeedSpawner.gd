extends Node2D

const SEED_RANDOM_POSITION = 5

var seedNode = preload("res://Nodes/Fertilizer.tscn")

func start_creating():
	if $AnimationPlayer.is_playing():
		yield($AnimationPlayer, "animation_finished")
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
