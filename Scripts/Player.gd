extends KinematicBody2D

enum States {MOVING, DASHING, PAUSED} 



var direction = Vector2.ZERO
var inputVector = Vector2.ZERO
var speed = 7000
var dash_speed = 12000

var carrying = false
var state = States.MOVING

onready var CarryPosition = $CarryPosition
onready var DashTimer = $DashTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	global.player = self


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
	move_and_slide(inputVector * speed * delta)

func dash_state(delta):
	controls()
	move_and_slide(direction * dash_speed * delta)

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
	uiManager.create_reticle()

func stop_carry():
	carrying = false
	

func _on_DashTimer_timeout():
	if state == States.DASHING:
		state = States.MOVING
