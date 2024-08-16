extends KinematicBody2D


enum States {IDLE, FOLLOWING, THROWN}
var state = States.IDLE
var speed = 7000
var idx = -1
var throw_height = -40

onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween
onready var anchor = $Anchor

func _ready():
	start_following()

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
	var newPosition = global.trailPositions[idx * global.trailOffset]
	var difference = position - newPosition
	if abs(difference.x) > 5 or abs(difference.y) > 5:
		var direction = global_position.direction_to(newPosition)
		move_and_slide(direction * speed * delta)
		animationPlayer.play("Walk")
	else:
		animationPlayer.play("Idle")



func throw(newPos, time):
	animationPlayer.play("Idle")
	global.remove_teenip(idx - 1)
	set_state(States.THROWN)
	tween.interpolate_property(self, "position", 
		position, newPos, time)
	tween.interpolate_property(anchor, "position:y", 
		anchor.position.y, throw_height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		throw_height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	tween.connect("tween_all_completed", self, "start_following", [], CONNECT_ONESHOT)
	

func set_state(newState):
	state = newState

func start_following():
	global.teenipsFollowing.append(self)
	idx = global.teenipsFollowing.size()
	set_state(States.FOLLOWING)
