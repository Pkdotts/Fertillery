extends KinematicBody2D

enum States {MOVING, DASHING, PAUSED} 

const WALKSPEED = 6500
const DASHSPEED = 20000
const DECELERATION = 50000

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

# Called when the node enters the scene tree for the first time.
func _ready():
	global.player = self
	uiManager.create_reticle()
	for i in global.trailPositions.size():
		
		global.trailPositions.push_front(position)
		global.trailPositions.pop_back()


func _input(event):
	if event.is_action_pressed("ui_shift") and !carrying:
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
	

func move(dir, spd, delta):
	var oldPos = position
	move_and_slide(dir * spd * delta)
	
	if position != oldPos:
		moving = true
		update_party_positions(oldPos, 1)

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
	if carrying:
		heldItem.throw(pos, 0.5)
		set_held_item(null)
	elif global.dripletsFollowing.size() > 0 and global.dripletsFollowing[0].position.distance_to(position) < throwableDistance:
		global.dripletsFollowing[0].throw(pos, 0.5)

func _on_DashTimer_timeout():
	if state == States.DASHING:
		state = States.MOVING
		AfterImageCreator.stop_creating()
