extends KinematicBody2D

export var size = 1

enum States {IDLE, MOVING, HELD, THROWN}
var state = States.IDLE

func _ready():
	pass

func _physics_process(delta):
	match state:
		States.IDLE:
			idle_state()
		States.MOVING:
			move_state()
		States.HELD:
			held_state()
		States.THROWN:
			thrown_state()

func idle_state():
	pass

func move_state():
	pass

func held_state():
	global_position = global.player.CarryPosition.global_position

func thrown_state():
	pass

func set_state(newState):
	state = newState

func grow():
	size += 1
	set_size(size)

func set_size(bigness):
	scale = Vector2(bigness, bigness)


func _on_Hitbox_body_entered(body):
	if body == global.player and global.player.state == global.player.States.DASHING and !global.player.carrying:
		set_state(States.HELD)


func _on_Absorber_area_entered(area):
	var driplet = area.get_parent().get_parent()
	driplet.die()
	grow()
