extends KinematicBody2D


signal stopped_shaking
signal maxGrow

const STARTSPEED = 40
var speed = 40
export var size = 3




enum States {IDLE, MOVING}
var state = States.IDLE

var sfx = {
	"extinguish": preload("res://Audio/SFX/extinguish.wav")
}

var max_size = 3
var runAway = false
var targetPosition = Vector2.ZERO
var runningFrom = []
var queuedEaten = false

onready var anchor = $Anchor
onready var animationPlayer = $AnimationPlayer
onready var tween = $Tween

func _ready():
	material = material.duplicate()
	speed = round(STARTSPEED * (1 + (size - 1) * 0.5))


func _physics_process(delta):
	$Anchor/GrowSprite.flip_h = $Anchor/Sprite.flip_h
	if size > 1:
		$Anchor/GrowSprite.frame = $Anchor/Sprite.frame - 3
	match state:
		States.IDLE:
			idle_state()
		States.MOVING:
			move_state(delta)

func idle_state():
	animationPlayer.play("Idle" + str(size))
	position = position.round()

func move_state(delta):
	if size > 1:
		move_towards_target()

func set_state(newState):
	state = newState

func grow():
	$GrowAnim.stop()
	$GrowAnim.play("Grow")
	size -= 1
	speed = round(STARTSPEED * (1 + (size - 1) * 0.5))
	$Timer.start(8.0)
	if size == 1:
		$CollisionShape2D.disabled = true


func _on_Absorber_area_entered(area):
	if size > 1:
		var driplet = area.get_parent().get_parent()
		if driplet.visible:
			var sound = sfx["extinguish"]
			driplet.die(sound)
			grow()

func choose_random_position():
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
	if size < 2:
		set_state(States.IDLE)
		targetPosition = position
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
		if runningTarget.name == "Turnip" and runningTarget.flash != true:
			direction = self.global_position.direction_to(runningTarget.global_position)
			#print("MILF DETECTED")
		else:
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
		if body.get("size") != null and body.size > 1:
			runAway = true
			choose_random_position()
			runningFrom.append(body)
			
			print("KILL YOURSELF" + body.name)


func _on_SafeArea_body_exited(body):
	if body != self:
		if runningFrom.has(body):
			runningFrom.erase(body)
			print("erased" + str(body))
		if runningFrom.size() == 0:
			runAway = false  # stop acting like a pussy
			choose_random_position()
			print("all erased")



#func _on_FleeArea_body_exited(body):
#	if runningFrom.has(body):
#		runningFrom.erase(body)
#		print("erased" + str(body))
#	if runningFrom.size() == 0:
#		runAway = false  # stop acting like a pussy
#		choose_random_position()
#		print("all erased")


func _on_Timer_timeout():
	if size < 3 and !$GrowAnim.is_playing():
		size += 1
		$GrowAnim.play("Grow")
		$CollisionShape2D.disabled = false
		speed = round(STARTSPEED * (1 + (size - 2) * 0.5))
		$Timer.start()



func _on_killer_body_entered(body):
	if body.name == "Turnip" and body.flash == false:
		body.hurt()
