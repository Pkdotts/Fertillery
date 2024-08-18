extends Node

export var tutorial = false

export var monsterPath : NodePath
onready var monster = get_node_or_null(monsterPath)

export var binPath : NodePath
onready var bin = get_node_or_null(binPath)

export var nextMap = ""
export var monsterDropPosition = 0



onready var screamSFX = preload("res://Audio/SFX/fiendroar.wav")

func _ready():
	global.connect("updateTurnipCounter", self, "check_threshold")
	if tutorial:
		if bin != null:
			bin.connect("ate", self, "play_intro_cutscene")

func check_threshold():
	if global.turnipsEaten >= global.nextThreshold and monster != null:
		play_inhale_cutscene()

func play_intro_cutscene():
	$Tween.interpolate_property(monster, "position:y",
		monster.position.y, monsterDropPosition, 1)
	$Tween.start()
	yield(get_tree().create_timer(0.8), "timeout")
	bin.die()
	yield(get_tree().create_timer(0.8), "timeout")
	monster.roar()
	audioManager.play_sfx(screamSFX, "scream")
	yield(get_tree().create_timer(2), "timeout")
	
	

func play_inhale_cutscene():
	global.player.pause()
	global.currentCamera.set_anchor(monster.cameraZoomPos)
	global.currentCamera.update_offset(Vector2(-100, 0), 0.05)
	global.pause_meter()
	yield(get_tree().create_timer(2), "timeout")
	monster.inhale()
	audioManager.play_sfx(screamSFX, "scream")
	yield(get_tree().create_timer(2), "timeout")
	global.currentCamera.update_offset(Vector2(0, 0), 1)
	global.currentCamera.zoom_in(1)
	yield(get_tree().create_timer(1), "timeout")
	global.change_scenes("res://Maps/" + nextMap + ".tscn")
	global.nextThreshold += global.THRESHOLDADDER
	
