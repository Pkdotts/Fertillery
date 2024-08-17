extends KinematicBody2D

export var speed = 100
export var size = 1




enum States {IDLE, MOVING, HELD, THROWN}
var state = States.IDLE


var max_size = 5
var throw_height = -40
var runAway = false
var targetPosition = Vector2.ZERO
var runningFrom = []

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
			move_state(delta)
		States.HELD:
			held_state()
		States.THROWN:
			thrown_state()
	
	position = position.round()

func idle_state():
	animationPlayer.play("Idle" + str(size))

func move_state(delta):
	move_towards_target()

func held_state():
	global_position = global.player.CarryPosition.global_position

func thrown_state():
	pass

func set_state(newState):
	state = newState

func grow():
	size += 1
	speed = round(150 / (1 + (size - 1) * 0.5))

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
	$MoveTime.start(0.5)

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




func choose_random_position():
	
	if state == States.HELD:
		return # if this little [insert slur here] is behind held, he stops moving
	
	var shape = $WanderRadius/CollisionShape2D.shape
	
	var radius = shape.radius
	var randomAngle = randf() * PI * 2
	var randomRadius = randf() * radius
	
	var offset = Vector2(cos(randomAngle), sin(randomAngle)) * randomRadius
	targetPosition = self.position + offset
	
	
	var rng = RandomNumberGenerator.new()
	
	# if targetPosition is so close to the current position then offset target position by 16
	if position.distance_to(targetPosition) < 8:
		
		var newPos = Vector2(16 * rng.randi_range(-1,1), 16 * rng.randi_range(-1,1))
		
		targetPosition += newPos
	

	set_state(States.MOVING)
	

func _on_MoveTime_timeout():
	choose_random_position()


func move_towards_target():
	var direction: Vector2
	
	animationPlayer.play("Walk" + str(size))
	
	var spd = speed
	
	if runAway and runningFrom != []:
		animationPlayer.playback_speed = 2
		var runningTarget = runningFrom[0]
		#turnip prioritizes running away from walls instead of player
		for i in runningFrom:
			runningTarget = i
			if runningFrom.size() > 1 and runningTarget == global.player:
				continue
			else:
				break
		direction = (position - runningTarget.position).normalized()
		spd = speed * 1.2
		targetPosition = position + direction * ($FleeArea/CollisionShape2D.shape.radius * 2)  # RUN BITCH
	
	else:
		animationPlayer.playback_speed = 1.5
		spd = speed
		direction = (targetPosition - position).normalized()
	
	
	
	if direction.round().x == -1 or direction.round().y == -1:
		$Anchor/Sprite.flip_h = true
	else:
		$Anchor/Sprite.flip_h = false

	var movement = direction * spd * get_process_delta_time()

	if position.distance_to(targetPosition) > movement.length():
		position += movement
	else:
		position = targetPosition
		set_state(States.IDLE)
		var rng = RandomNumberGenerator.new()
		$MoveTime.start(rng.randf_range(0.5,2))
		





func _on_FleeArea_body_entered(body):
	runAway = true
	choose_random_position()
	runningFrom.append(body)


func _on_SafeArea_body_exited(body):
	runAway = false  # stop acting like a pussy
	runningFrom.erase(body)
