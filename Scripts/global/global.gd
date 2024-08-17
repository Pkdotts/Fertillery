extends Node


var winSize = 1
var winDim = Vector2(384, 216)
var player = null
var currentCamera = null

var randomFollowerOffset = 5
var trailOffset = 10
var trailSize = 255
var trailPositions = []
var dripletsFollowing = []



func remove_driplet(idx = 0):
	dripletsFollowing.remove(0)
	for i in dripletsFollowing.size():
		dripletsFollowing[i].idx = i + 1

func _ready():
	trailPositions.resize(trailSize)
	increase_win_size(2)


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
