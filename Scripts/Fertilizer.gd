extends KinematicBody2D

onready var tween = $Tween
onready var anchor = $Anchor

enum States {IDLE, HELD, THROWN, MIDAIR}
var state = States.IDLE
var throwSpeed = 0
var throwDir = Vector2.ZERO

func _physics_process(delta):
	match state:
		States.HELD:
			held_state()
		States.MIDAIR:
			midair_state()
		States.THROWN:
			thrown_state(delta)

func held_state():
	global_position = global.player.CarryPosition.global_position
	
	if global.player.direction.x < 0:
		$Anchor/Sprite.flip_h = true
	elif global.player.direction.x > 0:
		$Anchor/Sprite.flip_h = false

func midair_state():
	global_position = lerp(global_position, global.player.CarryPosition.global_position.round(), 0.3) 

func thrown_state(delta):
	var velocity = throwDir * throwSpeed * delta
	move_and_slide(velocity)

func set_state(newState):
	state = newState

func throw(height, newPos, time):
	jump_to(newPos, time, height)
	calculate_trajectory(newPos, time)
	yield(get_tree().create_timer(time/3*2),"timeout")
	$Anchor/Area2D/CollisionShape2D.set_deferred("disabled", false)

func calculate_trajectory(newPos, time):
	var distance = position.distance_to(newPos)
	throwSpeed = (distance/time)/get_physics_process_delta_time()
	throwDir = position.direction_to(newPos)

func jump_to(newPos, time, height):
	if newPos.x < position.x:
		$Anchor/Sprite.flip_h = true
	elif newPos.x > position.x:
		$Anchor/Sprite.flip_h = false
	
	set_state(States.THROWN)
	tween.interpolate_property(anchor, "position:y", 
		anchor.position.y, height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	tween.connect("tween_all_completed", self, "land", [], CONNECT_ONESHOT)

func die():
	if global.player.heldItem == self:
		global.player.set_held_item(null)
	queue_free()

func land():
	state = States.IDLE
	$Anchor/Area2D/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	set_collisions(true)

func flip(height, time):
	#animationPlayer.play("Throw" + str(size))
	state = States.MIDAIR
	tween.interpolate_property(anchor, "position:y", 
		anchor.position.y, height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	
	tween.connect("tween_all_completed", self, "set_held", [], CONNECT_ONESHOT)

func set_held():
	state = States.HELD
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)

func set_collisions(enabled):
	$CollisionShape2D.set_deferred("disabled", !enabled)
