extends Camera2D

signal stoped_shaking


export var anchor_path : NodePath
export var anchor_offset = Vector2(0, -10)
export var drag = 0.3
const cam_limit = 50

var inputVector = Vector2.ZERO
var current_offset = Vector2.ZERO #used for knowing the normal offset when shaking it
var camareas = 0
var shaking = false

onready var anchor = get_node_or_null(anchor_path)

func _ready():
	global.currentCamera = self

func _physics_process(_delta):
	if anchor != null:
		position = lerp(position, anchor.position, drag) + anchor_offset


func move_camera(position_x,position_y, time):
	$Tween.interpolate_property(self,"global_position",
		get_camera_screen_center(), Vector2(position_x,position_y), time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()

func move_offset(offset_x,offset_y, time):
	var new_pos = global_position + Vector2(offset_x, offset_y)
	if new_pos.y - global.winDim.y/2 < limit_top and offset_y < 0:
		if global_position.y - global.winDim.y/2 > limit_top:
			offset_y = limit_top - global_position.x - global.winDim.y/2
		else:
			offset_y = 0
	if new_pos.y + global.winDim.y/2 > limit_bottom and offset_y > 0:
		if global_position.y + global.winDim.y/2 < limit_bottom:
			offset_y =  limit_bottom - global_position.y - global.winDim.y/2
		else:
			offset_y = 0
	if new_pos.x - global.winDim.x/2 < limit_left and offset_x < 0:
		if global_position.x - global.winDim.x/2 > limit_left:
			offset_x = limit_left - global_position.x - global.winDim.x/2
		else:
			offset_x = 0
	if new_pos.x + global.winDim.x/2 > limit_right and offset_x > 0:
		if global_position.x + global.winDim.x/2 < limit_right:
			offset_x =  limit_right - global_position.x - global.winDim.x/2
		else:
			offset_x = 0
	$Tween.interpolate_property(self,"offset",
		offset, Vector2(offset_x,offset_y), time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	current_offset = offset
	$Tween.start()

func return_camera(time = 1):
	$Tween.stop_all()
	$Tween.interpolate_property(self,"position",
		position, Vector2.ZERO, time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.start()
	
	yield($Tween,"tween_completed")
	
	position = Vector2.ZERO

func return_offset(time = 1):
	$Tween.stop_all()
	$Tween.interpolate_property(self,"offset",
		offset, Vector2.ZERO, time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.start()
	
	$Tween.interpolate_property(self,"position",
		position, Vector2.ZERO, time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	
	$Tween.start()
	
	yield($Tween,"tween_completed")
	
	position = Vector2.ZERO
	offset = Vector2.ZERO
	current_offset = offset

func reset():
	position = Vector2.ZERO
	offset = Vector2.ZERO

func shake_camera(magnitude = 1.0, time = 1.0, direction = Vector2.ONE):
	if !$Tween.is_active():
		var old_offset = current_offset
		var shake = magnitude
		shaking = true
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
			$Tween.interpolate_property(self, "offset",
				offset, new_offset, 0.02, 
				Tween.TRANS_QUART, Tween.EASE_OUT)
			$Tween.start()
			yield(get_tree().create_timer(.02), "timeout")
			if abs(shake) > 1:
				shake -= magnitude / int(time / .02)
				
		offset = old_offset
		shaking = false
		emit_signal("stoped_shaking")
