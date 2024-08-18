extends Node

export var monsterPath : NodePath
export var nextMap = ""

onready var monster = get_node_or_null(monsterPath)

onready var screamSFX = preload("res://Audio/SFX/fiendroar.wav")

func _ready():
	global.connect("updateTurnipCounter", self, "check_threshold")

func check_threshold():
	if global.turnipsEaten >= global.nextThreshold and monster != null:
		play_inhale_cutscene()

func play_inhale_cutscene():
	global.player.pause()
	global.currentCamera.set_anchor(monster.cameraZoomPos)
	global.currentCamera.update_offset(Vector2(-100, 0), 0.05)
	yield(get_tree().create_timer(2), "timeout")
	monster.inhale()
	audioManager.play_sfx(screamSFX, "scream")
	yield(get_tree().create_timer(2), "timeout")
	global.currentCamera.update_offset(Vector2(0, 0), 1)
	global.currentCamera.zoom_in(1)
	yield(get_tree().create_timer(1), "timeout")
	global.change_scenes("res://Maps/" + nextMap + ".tscn")
	global.hungerMeter = 0
	global.nextThreshold += global.THRESHOLDADDER
	
