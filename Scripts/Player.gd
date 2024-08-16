extends KinematicBody2D

enum STATES {IDLE, WALKING, PAUSED} 

var direction = Vector2.ZERO
var inputVector = Vector2.ZERO
var speed = 4000

var state

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	controls()
	move_and_slide(inputVector * speed * delta)

func controls():
	inputVector = controlsManager.get_controls_vector(false)
	if inputVector != Vector2.ZERO:
		print(inputVector)
		direction = inputVector
