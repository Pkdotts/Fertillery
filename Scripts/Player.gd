extends KinematicBody2D

enum States {MOVING, DASHING, PAUSED} 


var moving = false
var direction = Vector2.ZERO
var inputVector = Vector2.ZERO
var speed = 7000
var dash_speed = 12000
var throwableDistance = 60

var carrying = false
var state = States.MOVING



onready var CarryPosition = $CarryPosition
onready var DashTimer = $DashTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	global.player = self
	uiManager.create_reticle()
	for i in global.trailPositions.size():
		var randX = rand_range(-global.randomFollowerOffset, global.randomFollowerOffset)
		var randY = rand_range(-global.randomFollowerOffset, global.randomFollowerOffset)
		var randomOffset = Vector2(randX, randY)
		global.trailPositions.push_front(position + randomOffset)
		global.trailPositions.pop_back()


func _input(event):
	if event.is_action_pressed("ui_shift"):
		start_dash()

func _physics_process(delta):
	match state:
		States.MOVING:
			move_state(delta)
		States.DASHING:
			dash_state(delta)
		

func move_state(delta):
	controls()
	move(inputVector, speed, delta)

func dash_state(delta):
	move(direction, dash_speed, delta)

func move(dir, spd, delta):
	var oldPos = position
	move_and_slide(dir * spd * delta)
	
	if position != oldPos:
		moving = true
		update_party_positions(oldPos, 1)

func update_party_positions(oldpos, multiplier = 1):
	var maxDist = round(max(abs(oldpos.x-self.position.x), abs(oldpos.y-self.position.y)) * multiplier)
	for i in maxDist:
		var randX = rand_range(-global.randomFollowerOffset, global.randomFollowerOffset)
		var randY = rand_range(-global.randomFollowerOffset, global.randomFollowerOffset)
		var randomOffset = Vector2(randX, randY)
		global.trailPositions.push_front(lerp(oldpos, position.round() + randomOffset, (i+1)/maxDist))
		global.trailPositions.pop_back()



func controls():
	inputVector = controlsManager.get_controls_vector(false)
	if inputVector != Vector2.ZERO:
		print(inputVector)
		direction = inputVector

func start_dash():
	DashTimer.start()
	state = States.DASHING

func start_carry():
	carrying = true

func stop_carry():
	carrying = false

func throw_driplet(pos):
	if global.dripletsFollowing[0].position.distance_to(position) < throwableDistance:
		global.dripletsFollowing[0].throw(pos, 0.5)

func _on_DashTimer_timeout():
	if state == States.DASHING:
		state = States.MOVING
