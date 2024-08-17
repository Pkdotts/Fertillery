extends KinematicBody2D

export var size = 1



enum States {IDLE, MOVING, HELD, THROWN}
var state = States.IDLE


var max_size = 5
var throw_height = -40



onready var anchor = $Anchor
onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween


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
	animationPlayer.play("Idle" + str(size))

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

func throw(newPos, time):
	animationPlayer.play("Throw" + str(size))
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
	tween.connect("tween_all_completed", self, "land", [], CONNECT_ONESHOT)
	yield(get_tree().create_timer(time/3*2),"timeout")
	$Anchor/Eatbox/CollisionShape2D.disabled = false

func die():
	if global.player.heldItem == self:
		global.player.set_held_item(null)
	queue_free()

func land():
	$Anchor/Eatbox/CollisionShape2D.disabled = true
	set_state(States.IDLE)

func set_held():
	set_state(States.HELD)
	global.player.set_held_item(self)
	animationPlayer.play("Throw" + str(size))
	

func _on_Hitbox_body_entered(body):
	if body == global.player and global.player.state == global.player.States.DASHING and !global.player.carrying:
		set_held()


func _on_Absorber_area_entered(area):
	if size < 5:
		var driplet = area.get_parent().get_parent()
		driplet.die()
		grow()
