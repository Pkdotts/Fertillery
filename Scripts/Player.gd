extends KinematicBody2D

enum States {MOVING, DASHING, PAUSED} 

const WALKSPEED = 6500
const DASHSPEED = 20000
const DECELERATION = 50000
const FLIPHEIGHT = 32
const THROWHEIGHT = -40

var heldItem = null

var moving = false
var direction = Vector2.ZERO
var inputVector = Vector2.ZERO
var speed = 6500
var throwableDistance = 100


var carrying = false
var state = States.MOVING



onready var CarryPosition = $CarryPosition
onready var DashTimer = $DashTimer
onready var AfterImageCreator = $AfterImageCreator
onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$TackleArea/CollisionShape2D.disabled = true
	global.player = self
	uiManager.create_reticle()
	for i in global.trailPositions.size():
		
		global.trailPositions.push_front(position)
		global.trailPositions.pop_back()


func _input(event):
	if event.is_action_pressed("ui_shift") and !carrying and state != States.PAUSED:
		start_dash()

func _physics_process(delta):
	match state:
		States.MOVING:
			move_state(delta)
		States.DASHING:
			dash_state(delta)
		

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
	var oldPos = position
	move_and_slide(dir * spd * delta)
	
	if position != oldPos:
		moving = true
		update_party_positions(oldPos, 1)
		hold_play("Walk")
	else:
		moving = false
		hold_play("Idle")
	
	if animationPlayer.current_animation != "Throw":
		if round(oldPos.x) < round(position.x):
			$Sprite.flip_h = false
		elif round(oldPos.x) > round(position.x):
			$Sprite.flip_h = true

func update_party_positions(oldpos, multiplier = 1):
	var maxDist = round(max(abs(oldpos.x-self.position.x), abs(oldpos.y-self.position.y)) * multiplier)
	for i in maxDist:
		global.trailPositions.push_front(lerp(oldpos, position.round(), (i+1)/maxDist))
		global.trailPositions.pop_back()



func controls():
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
	var thrown = false
	if carrying:
		#can't throw while item is in midair
		if heldItem.state != heldItem.States.HELD:
			return
		heldItem.throw(THROWHEIGHT, pos, 0.5)
		set_held_item(null)
		$ThrowSound.play()
		thrown = true
	elif global.dripletsFollowing.size() > 0 and global.dripletsFollowing[0].position.distance_to(position) < throwableDistance:
		global.dripletsFollowing[0].throw(THROWHEIGHT, pos, 0.5)
		thrown = true
	
	if thrown:
		animationPlayer.play("Throw")
		if pos.x > position.x:
			$Sprite.flip_h = false
		elif pos.x < position.x:
			$Sprite.flip_h = true


func stop_dashing():
	if state == States.DASHING:
		state = States.MOVING
		AfterImageCreator.stop_creating()
		$TackleArea/CollisionShape2D.disabled = true

func hold_play(anim):
	if animationPlayer.current_animation != "Throw" and state != States.DASHING:
		if carrying:
			animationPlayer.play(anim + "Hold")
		else:
			animationPlayer.play(anim)

func pause():
	state = States.PAUSED

func _on_DashTimer_timeout():
	stop_dashing()


func _on_TackleArea_area_entered(area):
	var parent = area.get_parent()
	print($TackleArea/CollisionShape2D.disabled)
	if state == States.DASHING and !carrying and parent.has_method("set_held") and parent.state != parent.States.THROWN:
		parent.flip(-FLIPHEIGHT, 0.5)
		set_held_item(parent)
		stop_dashing()
		global.currentCamera.shake_camera(2, 0.04, Vector2(1, 0))
