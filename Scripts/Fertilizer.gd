extends Node2D

onready var tween = $Tween
onready var anchor = $Anchor

enum States {IDLE, HELD, THROWN, MIDAIR}
var state = States.IDLE

var throw_height = -40


func _physics_process(delta):
	match state:
		States.HELD:
			held_state()
		States.MIDAIR:
			midair_state()

func held_state():
	global_position = global.player.CarryPosition.global_position

func midair_state():
	global_position = lerp(global_position, global.player.CarryPosition.global_position.round(), 0.3) 

func throw(newPos, time):
	state = States.THROWN
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
	$Anchor/Area2D/CollisionShape2D.set_deferred("disabled", false)


func die():
	if global.player.heldItem == self:
		global.player.set_held_item(null)
	queue_free()

func land():
	state = States.IDLE
	$Anchor/Area2D/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)

func flip(height, time):
	#animationPlayer.play("Throw" + str(size))
	state = States.MIDAIR
	tween.interpolate_property(anchor, "position:y", 
		anchor.position.y, height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	
	tween.connect("tween_all_completed", self, "set_held", [], CONNECT_ONESHOT)

func set_held():
	state = States.HELD
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
