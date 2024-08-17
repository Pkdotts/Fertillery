extends Node2D

onready var tween = $Tween
onready var anchor = $Anchor

var held = false
var throw_height = -40


func _physics_process(delta):
	if held:
		global_position = global.player.CarryPosition.global_position

func throw(newPos, time):
	held = false
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
	$Anchor/Area2D/CollisionShape2D.disabled = false

func die():
	if global.player.heldItem == self:
		global.player.set_held_item(null)
	queue_free()

func land():
	$Anchor/Area2D/CollisionShape2D.disabled = true

func set_held():
	held = true
	global.player.set_held_item(self)

func _on_Hitbox_body_entered(body):
	if body == global.player and global.player.state == global.player.States.DASHING and !global.player.carrying:
		set_held()
