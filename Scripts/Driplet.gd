extends KinematicBody2D


enum States {IDLE, FOLLOWING, THROWN, SPAWNING}
var state = States.IDLE
var speed = 8200
var idx = -1
var throw_height = -40
var followPositionOffset = Vector2.ZERO

var throwSpeed = 0
var throwDir = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween
onready var anchor = $Anchor

func _ready():
	$AnimationPlayer.play("Idle")
	global.dripCount += 1
	var randX = rand_range(-global.randomFollowerOffset, global.randomFollowerOffset)
	var randY = rand_range(-global.randomFollowerOffset, global.randomFollowerOffset)
	followPositionOffset = Vector2(randX, randY).round()

func _physics_process(delta):
	match state:
		States.IDLE:
			idle_state()
		States.FOLLOWING:
			follow_state(delta)
		States.THROWN:
			thrown_state(delta)

func idle_state():
	pass

func follow_state(delta):
	var oldPos = position
	var newPosition = global.trailPositions[idx * global.trailOffset] + followPositionOffset
	var difference = position - newPosition
	if abs(difference.x) > 5 or abs(difference.y) > 5:
		var direction = global_position.direction_to(newPosition)
		move_and_slide(direction * speed * delta)
		$AnimationPlayer.play("Walk")
	elif global.player.moving and !global.player.paused:
		$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Idle")
	if round(oldPos.x) > round(position.x):
		$Anchor/Sprite.flip_h = true
	elif round(oldPos.x) < round(position.x):
		$Anchor/Sprite.flip_h = false

func thrown_state(delta):
	var velocity = throwDir * throwSpeed * delta
	move_and_slide(velocity)

func throw(height, newPos, time, initHeight = 0):
	jump_to(newPos, time, height, initHeight)
	calculate_trajectory(newPos, time)
	yield(get_tree().create_timer(time/3*2),"timeout")
	$Anchor/Hitbox/CollisionShape2D.set_deferred("disabled", false)

func calculate_trajectory(newPos, time):
	var distance = position.distance_to(newPos)
	throwSpeed = (distance/time)/get_physics_process_delta_time()
	throwDir = position.direction_to(newPos)

func jump_to(newPos, time, height, initHeight = 0):
	animationPlayer.play("Thrown")
	play_throw_sfx()
	if newPos.x < position.x:
		$Anchor/Sprite.flip_h = true
	elif newPos.x > position.x:
		$Anchor/Sprite.flip_h = false
	
	height += initHeight
	
	set_state(States.THROWN)
	tween.interpolate_property(anchor, "position:y", 
		initHeight, height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	tween.connect("tween_all_completed", self, "land", [], CONNECT_ONESHOT)

func land():
	start_following()
	$Anchor/Hitbox/CollisionShape2D.disabled = true

func play_throw_sfx():
	$AudioStreamPlayer.pitch_scale = rand_range(0.8, 1.2)
	$AudioStreamPlayer.play(0.01)
	global.remove_driplet(idx - 1)

func spawn():
	state = States.SPAWNING
	$ViewArea/CollisionShape2D.disabled = true
	var dropPosition = Vector2(position.x - 212, position.x - 424)
	$AnimationPlayer.play("Falling")
	tween.interpolate_property(self, "position", 
		dropPosition, position, 1)
	tween.start()
	yield(tween, "tween_all_completed")
	$AudioStreamPlayer2D.play(0.01)
	$AnimationPlayer.play("Drop")
	yield($AnimationPlayer, "animation_finished")
	set_state(States.IDLE)
	$ViewArea/CollisionShape2D.disabled = false


func die(sfx = null):
	global.dripCount -= 1
	set_physics_process(false)
	hide()
	if sfx != null:
		$AudioStreamPlayer.pitch_scale = 1
		$AudioStreamPlayer.stream = sfx
		$AudioStreamPlayer.play()
		yield($AudioStreamPlayer,"finished")
	queue_free()

func set_state(newState):
	state = newState

func start_following():
	if visible:
		global.dripletsFollowing.append(self)
		idx = global.dripletsFollowing.size()
		set_state(States.FOLLOWING)


func _on_ViewArea_body_entered(body):
	if body == global.player and state == States.IDLE:
		start_following()
