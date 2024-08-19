extends Node

export var tutorial = false

export var monsterPath : NodePath
onready var monster = get_node_or_null(monsterPath)

export var binPath : NodePath
onready var bin = get_node_or_null(binPath)

export var seedSpawnerPath : NodePath
onready var seedSpawner = get_node_or_null(seedSpawnerPath)

export var holePath : NodePath
onready var hole = get_node_or_null(holePath)

export var dripletSpawnerPath : NodePath
onready var dripletSpawner = get_node_or_null(dripletSpawnerPath)

export var nextMap = ""
export var monsterDropPosition = 0



onready var screamSFX = preload("res://Audio/SFX/fiendroar.wav")
onready var fallSFX = preload("res://Audio/SFX/fiendfallin.wav")
onready var explodeSFX = preload("res://Audio/SFX/cratebreak.wav")

func _ready():
	global.connect("updateTurnipCounter", self, "check_threshold")
	if tutorial:
		audioManager.play_ambiance_music()
		if bin != null:
			bin.connect("ate", self, "play_intro_cutscene")
		if seedSpawner != null:
			yield(get_tree().create_timer(1),"timeout")
			create_seed()
		if hole != null and dripletSpawner != null:
			hole.connect("created_turnip", dripletSpawner, "set_spawning", [true], CONNECT_ONESHOT)
		

func create_seed():
	if seedSpawner != null:
		seedSpawner.start_creating()


func check_threshold():
	if global.turnipsEaten >= global.nextThreshold and monster != null:
		play_inhale_cutscene()

func bin_slide_in():
	var endBinPos = 432
	if global.player.position.x > 256:
		bin.position.x = endBinPos + 500
	else:
		bin.position.x = endBinPos - 500
	$Tween.interpolate_property(bin, "position:x",
		bin.position.x, endBinPos, 1)
	$Tween.start()

func play_intro_cutscene():
	$Tween.interpolate_property(monster, "position:y",
		monster.position.y, monsterDropPosition, 1)
	$Tween.start()
	audioManager.stop_ambiance_music()
	audioManager.play_sfx(fallSFX, "explosion")
	yield(get_tree().create_timer(0.8), "timeout")
	bin.die()
	audioManager.play_sfx(explodeSFX, "explosion")
	yield(get_tree().create_timer(2), "timeout")
	monster.roar()
	audioManager.play_sfx(screamSFX, "scream")
	yield(get_tree().create_timer(2), "timeout")
	monster.idle()
	yield(get_tree().create_timer(5), "timeout")
	
	audioManager.play_game_music()
	uiManager.create_HUD()
	create_seed()
	

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
	
