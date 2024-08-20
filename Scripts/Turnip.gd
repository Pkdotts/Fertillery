extends KinematicBody2D


signal stopped_shaking
signal maxGrow

const STARTSPEED = 80

export var speed = 80
export var size = 1





enum States {IDLE, MOVING, HELD, THROWN, MIDAIR, HIT}
var state = States.IDLE

var sfx = {
	"grow": preload("res://Audio/SFX/turnipgrow.wav"),
	"maxgrow": preload("res://Audio/SFX/maxsize.wav")
}

var max_size = 6
var runAway = false
var targetPosition = Vector2.ZERO
var runningFrom = []
var throwSpeed = 0
var throwDir = Vector2.ZERO
var queuedEaten = false
var flash = false

onready var anchor = $Anchor
onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween

func _ready():
	material = material.duplicate()
	global.turnipCount += 1

func set_tutorial_turnip(cutscene):
	connect("maxGrow", cutscene, "bin_slide_in", [], CONNECT_ONESHOT)

func _physics_process(delta):
	$Anchor/GrowSprite.flip_h = $Anchor/Sprite.flip_h
	$Anchor/GrowSprite.rotation = $Anchor/Sprite.rotation
	if size > 1 and $Anchor/Sprite.frame - 4 >= 0:
		$Anchor/GrowSprite.frame = $Anchor/Sprite.frame - 4
	match state:
		States.IDLE:
			idle_state()
		States.MOVING:
			move_state(delta)
		States.HELD:
			held_state()
		States.THROWN:
			thrown_state(delta)
		States.MIDAIR:
			midair_state()

func idle_state():
	animationPlayer.play("Idle" + str(size))
	position = position.round()

func move_state(_delta):
	move_towards_target()

func held_state():
	global_position = global.player.global_position + Vector2(0, 1)
	anchor.position.y = round(global.player.CarryPosition.position.y) + 5
	if global.player.direction.x < 0:
		$Anchor/Sprite.flip_h = true
	elif global.player.direction.x > 0:
		$Anchor/Sprite.flip_h = false

func thrown_state(delta):
	var velocity = throwDir * throwSpeed * delta
	move_and_slide(velocity)

func midair_state():
	global_position = lerp(global_position, global.player.CarryPosition.global_position.round(), 0.3) 

func set_state(newState):
	state = newState

func grow():
	$GrowAnim.stop()
	$GrowAnim.play("Grow")
	size += 1
	speed = round(STARTSPEED / (1 + (size - 1) * 0.5))
	if size == max_size:
		emit_signal("maxGrow")

func throw(height, newPos, time, initHeight = 0):
	jump_to(newPos, time, height, initHeight)
	calculate_trajectory(newPos, time)
	set_collision_layer_bit(3, false)
	yield(get_tree().create_timer(time/3*2),"timeout")
	$Anchor/Eatbox/CollisionShape2D.set_deferred("disabled", false)
	

func calculate_trajectory(newPos, time):
	var distance = position.distance_to(newPos)
	throwSpeed = (distance/time)/get_physics_process_delta_time()
	throwDir = position.direction_to(newPos)

func jump_to(newPos, time, height, initHeight = 0):
	if newPos.x < position.x:
		$Anchor/Sprite.flip_h = true
	elif newPos.x > position.x:
		$Anchor/Sprite.flip_h = false
	
	height += initHeight
	
	animationPlayer.play("Throw" + str(size))
	set_state(States.THROWN)
	tween.interpolate_property(anchor, "position:y", 
		initHeight, height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		height, 0, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	tween.connect("tween_all_completed", self, "land", [], CONNECT_ONESHOT)

func flip(height, time):
	#set_state(States.HIT)
	animationPlayer.play("Throw" + str(size))
	#shake_sprite(5, 0.02, Vector2(1, 0))
	
	#yield(self, "stopped_shaking")
	set_state(States.MIDAIR)
	tween.interpolate_property(anchor, "position:y", 
		anchor.position.y, height, time/2,
		Tween.TRANS_QUAD,Tween.EASE_OUT)
	tween.interpolate_property(anchor, "position:y", 
		height, anchor.position.y, time/2,
		Tween.TRANS_QUAD,Tween.EASE_IN, time/2)
	tween.start()
	
	tween.connect("tween_all_completed", self, "set_held", [], CONNECT_ONESHOT)

func shake_sprite(magnitude = 1.0, time = 1.0, direction = Vector2.ONE):
	if !$Tween.is_active():
		var old_pos = anchor.position
		var shake = magnitude
		if shake < 1.0:
			shake = 1.0
		if time < 0.2:
			time = 0.2
		for i in int(time / .02):
			var new_offset = Vector2.ZERO
			if abs(shake) > 1:
				shake = shake * -1
				magnitude = magnitude * -1
			else:
				if shake < 0.5:
					shake = 1.0
				else:
					shake = 0.0
			new_offset = Vector2(shake, shake) * direction
			#offset = new_offset
			$Tween.interpolate_property(anchor, "position",
				anchor.position, new_offset, 0.02, 
				Tween.TRANS_QUART, Tween.EASE_OUT)
			$Tween.start()
			yield(get_tree().create_timer(.02), "timeout")
			if abs(shake) > 1:
				shake -= magnitude / int(time / .02)
				
		anchor.position = old_pos
		emit_signal("stopped_shaking")

func die():
	if global.player.heldItem == self:
		global.player.set_held_item(null)
	global.remove_turnip()
	queue_free()

func land():
	set_state(States.IDLE)
	$MoveTime.start(0.5)
	$Anchor/Eatbox/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)
	set_collision_layer_bit(3, true)


func set_held():
	set_state(States.HELD)
	animationPlayer.play("Throw" + str(size))
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)

func _on_Absorber_area_entered(area):
	if size < max_size:
		var driplet = area.get_parent().get_parent()
		if driplet.visible:
			var sound = sfx["grow"]
			if size == 5:
				sound = sfx["maxgrow"]
			driplet.die(sound)
			grow()

func choose_random_position():
	
	if state == States.HELD or state == States.MIDAIR or state == States.THROWN:
		return # if this little [insert slur here] is behind held, he stops moving
	
	var shape = $WanderRadius/CollisionShape2D.shape
	
	var radius = shape.radius
	var randomAngle = randf() * PI * 2
	var randomRadius = randf() * radius
	
	var offset = Vector2(cos(randomAngle), sin(randomAngle)) * randomRadius
	targetPosition = self.position + offset
	
	$RayCast2D.cast_to = offset
	
	if $RayCast2D.get_collider() != null:
		return
	
	var rng = RandomNumberGenerator.new()
	
	# if targetPosition is so close to the current position then offset target position by 16
	if position.distance_to(targetPosition) < 16:
		
		var newPos = Vector2(16 * rng.randi_range(-1,1), 16 * rng.randi_range(-1,1))
		var dir = position.direction_to(newPos)
		var velocity = dir * speed * get_physics_process_delta_time()
		
		move_and_slide(velocity)

	set_state(States.MOVING)
	

func _on_MoveTime_timeout():
	choose_random_position()


func move_towards_target():
	
	if state == States.HELD or state == States.THROWN or state == States.MIDAIR:
		return
	
	var direction: Vector2
	
	animationPlayer.play("Walk" + str(size))
	
	var spd = speed
	
	if runAway and runningFrom != []:
		animationPlayer.playback_speed = 2
		var runningTarget = runningFrom[0]
		#turnip prioritizes running away from walls instead of player
		for i in runningFrom:
			
			if runningFrom.size() > 1 and i != global.player:
				runningTarget = i
				break
			elif runningFrom.size() == 0:
				runningTarget = i
				break
			
		direction = runningTarget.global_position.direction_to(global_position)
		spd = speed * 1.2
		targetPosition = position + direction * ($FleeArea/CollisionShape2D.shape.radius * 2)  # RUN BITCH
	
	else:
		animationPlayer.playback_speed = 1.5
		spd = speed
		direction = (targetPosition - position).normalized()
	
	
	
	if direction.x < 0:
		$Anchor/Sprite.flip_h = true
	elif direction.x > 0:
		$Anchor/Sprite.flip_h = false

	var movement = direction * spd * get_process_delta_time()

	if position.distance_to(targetPosition) > movement.length():
		move_and_collide(movement)
	else:
		position = targetPosition
		set_state(States.IDLE)
		var rng = RandomNumberGenerator.new()
		$MoveTime.start(rng.randf_range(0.5,2))

func _on_FleeArea_body_entered(body):
	if !runningFrom.has(body) and body != self:
		runAway = true
		choose_random_position()
		runningFrom.append(body)


func _on_SafeArea_body_exited(body):
	if body != self:
		if runningFrom.has(body):
			runningFrom.erase(body)
		if runningFrom.size() == 0:
			runAway = false  # stop acting like a pussy
			choose_random_position()

func hurt():
	$Flash.play("Flash")
	flash = true
	if size > 1:
		$GrowAnim.stop()
		$GrowAnim.play("Grow")
		size -= 1
		speed = round(150 / (1 + (size - 1) * 0.5))
	
func spawn():
	set_state(States.THROWN)
	jump_to(global_position, 0.3, -10, 0)

#func _on_FleeArea_body_exited(body):
#	if runningFrom.has(body):
#		runningFrom.erase(body)
#		print("erased" + str(body))
#	if runningFrom.size() == 0:
#		runAway = false  # stop acting like a pussy
#		choose_random_position()
#		print("all erased")


func _on_GrowAnim_animation_finished(anim_name):
	if anim_name == "Flash":
		flash = false
