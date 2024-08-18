extends Node

signal updateTurnipCounter
signal updateDripDelay(dripDelay)

var winSize = 1
var winDim = Vector2(384, 216)
var player = null
var currentCamera = null
var level = 1

var music = {
	"gameplay": "kevinthehonky (1).wav"
}

const LEVEL_STATS = {
	1: {
		"dripDelay": 2,
		"minDripDelay": 2,
		"maxDripCount": 10,
		
		"initHungerSpeed": 3,
		"maxHungerSpeed": 100
	}
}


const randomFollowerOffset = 5
const trailOffset = 10
const trailSize = 255
var trailPositions = []
var dripletsFollowing = []

var dripDelay = 5
var minDripDelay = 2
var dripCount = 0
var maxDripCount = 10

const THRESHOLDADDER = 30
var nextThreshold = 30
var turnipsEaten = 0
var hungerMeter = 0
var hungerSpeed = 3
var maxHungerSpeed = 100


func _ready():
	trailPositions.resize(trailSize)
	increase_win_size(2)
	if get_tree().current_scene is Node2D:
		uiManager.create_HUD()
	#audioManager.play_music("", music["gameplay"])

func increase_level(amt = 1):
	level += amt

func set_level(lvl):
	level = lvl

func increase_turnip_counter(num):
	turnipsEaten += num
	emit_signal("updateTurnipCounter")


func decrease_drip_delay(amount):
	dripDelay -= amount
	if dripDelay < minDripDelay:
		dripDelay = minDripDelay
	emit_signal("updateDripDelay", dripDelay)

func decrease_hunger(amount):
	hungerMeter -= amount
	if hungerMeter < 0:
		hungerMeter = 0
		

func increase_hunger_speed(amount):
	hungerSpeed += amount
	if hungerSpeed > maxHungerSpeed:
		hungerSpeed = maxHungerSpeed

func set_hunger_speed(speed):
	hungerSpeed = speed

func remove_driplet(idx = 0):
	dripletsFollowing.remove(0)
	for i in dripletsFollowing.size():
		dripletsFollowing[i].idx = i + 1

func reset_driplets():
	dripCount = 0
	dripletsFollowing.clear()

func increase_difficulty():
	increase_hunger_speed(0.2)
	decrease_drip_delay(0.5)

func _physics_process(delta):
	if !uiManager.fading:
		if hungerMeter < 100:
			if hungerMeter < 50:
				hungerMeter += delta * hungerSpeed
			elif hungerMeter < 80:
				hungerMeter += delta * hungerSpeed * 0.85
			else:
				hungerMeter += delta * hungerSpeed * 0.7
		else:
			uiManager.erase_HUD()
			change_scenes("res://Maps/gameOver.tscn")
			hungerMeter = 0
			

func _input(event):
	if event.is_action_pressed("ui_winsize"):
		increase_win_size(1)

func increase_win_size(amount):
	var newWinSize = winSize + amount

	if newWinSize < 1:
		newWinSize = int(OS.get_screen_size().x / winDim.x)

	if OS.get_screen_size() < Vector2(winDim.x * newWinSize, winDim.y * newWinSize):
		newWinSize = 1
	
	set_win_size(newWinSize)

func set_win_size(newSizeNum, fullscreen = false):
	# Everything here needs to happen asynchronously: sometimes resizing the window hangs the system for a few milliseconds, causing issues
	yield(get_tree(), "idle_frame")

	if fullscreen != OS.window_fullscreen:
		OS.window_fullscreen = fullscreen

	if not fullscreen:
		var oldSize = OS.window_size
		var newSize = Vector2(winDim.x * newSizeNum, winDim.y * newSizeNum)
		winSize = newSizeNum
		if newSize != oldSize:
			OS.window_borderless = false
			var newPos = OS.window_position - (newSize - oldSize) / 2
			# We don’t want the title bar to be out of screen
			var topLeft = OS.get_screen_position() + Vector2(OS.get_screen_size().x * .1, 0)
			var bottomRight = OS.get_screen_position() + OS.get_screen_size() * .9
			newPos.x = clamp(newPos.x, topLeft.x - newSize.x, bottomRight.x)
			newPos.y = clamp(newPos.y, topLeft.y, bottomRight.y)
			OS.set_window_size(newSize)
			OS.set_window_position(newPos)

	global.emit_signal("settings_changed")

func change_scenes(scene):
	uiManager.fading = true
	if uiManager.transition != null:
		uiManager.transition.queue_free()
		uiManager.transition = null
	uiManager.fade_in()
	yield(uiManager.transition, "transition_finished")
	get_tree().change_scene(scene)
	
	reset_driplets()
	uiManager.fade_out()
	yield(uiManager.transition, "transition_finished")
	if !get_tree().get_current_scene() is Control:
		uiManager.create_HUD()
	else:
		uiManager.erase_HUD()
	uiManager.fading = false
