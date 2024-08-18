extends KinematicBody2D


enum States {IDLE, FOLLOWING, THROWN, SPAWNING}
var state = States.IDLE
var speed = 7000
var idx = -1
var throw_height = -40
var followPositionOffset = Vector2.ZERO

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
			pass

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
	elif global.player.moving:
		$AnimationPlayer.play("Walk")
	else:
		$AnimationPlayer.play("Idle")
	if round(oldPos.x) > round(position.x):
		$Anchor/Sprite.flip_h = true
	elif round(oldPos.x) < round(position.x):
		$Anchor/Sprite.flip_h = false


func throw(newPos, time):
	$AudioStreamPlayer.pitch_scale = rand_range(0.8, 1.2)
	$AudioStreamPlayer.play(0.01)
	if position.x > newPos.x:
		$Anchor/Sprite.flip_h = true
	elif position.x < newPos.x:
		$Anchor/Sprite.flip_h = false
	global.remove_driplet(idx - 1)
	animationPlayer.play("Thrown")
	set_state(States.THROWN)
	tween.interpolate_property(self, "position", 
		global.player.position, newPos, time)
	tween.interpolate_property(anchor, "position:y", 
		anchor.position.y, throw_height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		throw_height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	tween.connect("tween_all_completed", self, "land", [], CONNECT_ONESHOT)
	yield(get_tree().create_timer(time/3*2),"timeout")
	$Anchor/Hitbox/CollisionShape2D.disabled = false

func land():
	start_following()
	$Anchor/Hitbox/CollisionShape2D.disabled = true

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
