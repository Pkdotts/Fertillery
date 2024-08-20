extends KinematicBody2D

signal paused

enum States {MOVING, DASHING} 

const WALKSPEED = 10000
const DASHSPEED = 21000
const DECELERATION = 45000
const FLIPHEIGHT = 32
const THROWHEIGHT = -40

var heldItem = null

var moving = false
var direction = Vector2.ZERO
var inputVector = Vector2.ZERO
var speed = 6500
var throwableDistance = 100

var paused = false
var carrying = false
var state = States.MOVING
var rotating = false

onready var CarryPosition = $CarryPosition
onready var DashTimer = $DashTimer
onready var AfterImageCreator = $AfterImageCreator
onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$TackleArea/CollisionShape2D.disabled = true
	global.player = self
	for i in global.trailPositions.size():
		
		global.trailPositions.push_front(position)
		global.trailPositions.pop_back()


func _input(event):
	if event.is_action_pressed("ui_shift") and !carrying and !paused:
		start_dash()

func _physics_process(delta):
	match state:
		States.MOVING:
			move_state(delta)
		States.DASHING:
			dash_state(delta)
	if rotating:
		$Sprite.rotation_degrees += 1000 * delta
	if heldItem != null:
		heldItem.scale = self.scale
		heldItem.get_node("Anchor/Sprite").rotation = $Sprite.rotation

func move_state(delta):
	controls()
	if speed > WALKSPEED:
		speed -= DECELERATION * delta
	else:
		speed = WALKSPEED
	move(inputVector, speed, delta)

func dash_state(delta):
	move(direction, speed, delta)

func start_dash():
	DashTimer.start()
	state = States.DASHING
	speed = DASHSPEED
	AfterImageCreator.start_creating()
	$TackleArea/CollisionShape2D.disabled = false
	$DashSound.play()
	animationPlayer.play("Dash")
	

func move(dir, spd, delta):
	if !paused:
		var oldPos = position
		move_and_slide(dir * spd * delta)
		
		if position.round() != oldPos.round():
			moving = true
			update_party_positions(oldPos, 1)
			hold_play("Walk")
		else:
			moving = false
			hold_play("Idle")
			position = position.round()
		
		if animationPlayer.current_animation != "Throw" and animationPlayer.current_animation != "Pickup":
			if round(oldPos.x) < round(position.x):
				$Sprite.flip_h = false
			elif round(oldPos.x) > round(position.x):
				$Sprite.flip_h = true
	else:
		hold_play("Idle")

func update_party_positions(oldpos, multiplier = 1):
	var maxDist = round(max(abs(oldpos.x-self.position.x), abs(oldpos.y-self.position.y)) * multiplier)
	for i in maxDist:
		global.trailPositions.push_front(lerp(oldpos, position, (i+1)/maxDist))
		global.trailPositions.pop_back()



func controls():
	if !paused:
		inputVector = controlsManager.get_controls_vector(false)
		if inputVector != Vector2.ZERO:
			direction = inputVector



func set_held_item(item = null):
	heldItem = item
	if item != null:
		carrying = true
	else:
		carrying = false

func throw(pos):
	if !paused:
		var thrown = false
		if carrying:
			#can't throw while item is in midair
			if heldItem.state != heldItem.States.HELD:
				return
			heldItem.global_position = global.player.global_position
			heldItem.throw(THROWHEIGHT, pos, 0.5, CarryPosition.position.y)
			set_held_item(null)
			$ThrowSound.play()
			thrown = true
		elif global.dripletsFollowing.size() > 0:
			var thrownDriplet = null
			
			for i in global.dripletsFollowing:
				if i.position.distance_to(position) < throwableDistance:
					thrownDriplet = i
			
			if thrownDriplet != null:
			
				global.dripletsFollowing[0].global_position = global.player.global_position
				global.dripletsFollowing[0].throw(THROWHEIGHT, pos, 0.5, CarryPosition.position.y)
				thrown = true
		
		if thrown:
			animationPlayer.stop()
			animationPlayer.play("Throw")
			if pos.x > position.x:
				$Sprite.flip_h = false
			elif pos.x < position.x:
				$Sprite.flip_h = true


func stop_dashing():
	if state == States.DASHING:
		state = States.MOVING
		AfterImageCreator.stop_creating()
		$TackleArea/CollisionShape2D.set_deferred("disabled", true)

func hold_play(anim):
	if animationPlayer.current_animation != "Throw" and animationPlayer.current_animation != "Pickup" and state != States.DASHING:
		if carrying:
			animationPlayer.play(anim + "Hold")
		else:
			animationPlayer.play(anim)

func pause():
	paused = true
	emit_signal("paused")

func unpause():
	paused = false



func _on_DashTimer_timeout():
	stop_dashing()


func _on_TackleArea_area_entered(area):
	var parent = area.get_parent()
	print($TackleArea/CollisionShape2D.disabled)
	if state == States.DASHING and !carrying and parent.has_method("set_held") and parent.state != parent.States.THROWN and parent.name != "Fire":
		parent.flip(-FLIPHEIGHT, 0.5)
		set_held_item(parent)
		stop_dashing()
		global.currentCamera.shake_camera(2, 0.04, Vector2(1, 0))
		animationPlayer.play("Pickup")
		$GrabSound.play()


func _on_Player_tree_exited():
	global.player = null
