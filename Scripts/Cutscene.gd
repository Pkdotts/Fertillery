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

export var monsterAnchorXOffset = -100


onready var screamSFX = preload("res://Audio/SFX/fiendroar.wav")
onready var fallSFX = preload("res://Audio/SFX/fiendfallin.wav")
onready var explodeSFX = preload("res://Audio/SFX/cratebreak.wav")

func _process(delta):
	if Input.is_action_just_pressed("ui_home") and OS.is_debug_build():
		play_inhale_cutscene()

func _ready():
	global.connect("updateTurnipCounter", self, "check_threshold")
	global.connect("gameOver", self, "play_game_over")
	if tutorial:
		seedSpawner.tutorial = true
		global.player.pause()
		audioManager.play_ambiance_music()
		if bin != null:
			bin.connect("ate", self, "play_intro_cutscene")
		
		if hole != null and dripletSpawner != null:
			hole.connect("created_turnip", dripletSpawner, "set_spawning", [true], CONNECT_ONESHOT)
	else:
		uiManager.show_reticle()
		uiManager.reticle.set_mode(0)

func start_game():
	uiManager.reticle.set_mode(0)
	global.currentCamera.set_anchor(global.player)
	global.player.unpause()
	global.nextThreshold = global.STARTTHRESHOLD
	global.level = 1
	if global.tutorialCompleted:
		play_intro_cutscene()
	else:
		if seedSpawner != null:
			yield(get_tree().create_timer(1),"timeout")
			create_seed()
		

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
	global.tutorial = false
	global.hungerMeter = 0
	$Tween.interpolate_property(monster, "position:y",
		monster.position.y, monsterDropPosition, 1)
	$Tween.start()
	audioManager.stop_ambiance_music()
	audioManager.play_sfx(fallSFX, "explosion")
	yield(get_tree().create_timer(0.8), "timeout")
	bin.die()
	audioManager.play_sfx(explodeSFX, "explosion")
	global.currentCamera.shake_camera(5.0, 0.4, Vector2(0, 1))
	if get_tree().get_current_scene().has_node("FLYFLY"):
		get_tree().get_current_scene().get_node("FLYFLY").play("fly")
	yield(get_tree().create_timer(2), "timeout")
	monster.roar()
	audioManager.play_sfx(screamSFX, "scream")
	yield(get_tree().create_timer(5), "timeout")
	monster.idle()
	yield(get_tree().create_timer(2), "timeout")
	global.start_timer()
	audioManager.play_game_music()
	uiManager.create_HUD()
	seedSpawner.tutorial = false
	create_seed()


func play_inhale_cutscene():
	if tutorial:
		global.tutorialCompleted = true
	var monsterZoomPos = monster.cameraZoomPos.global_position
	global.player.pause()
	uiManager.hide_reticle()
	global.currentCamera.set_anchor(null)
	global.currentCamera.move_camera(monsterZoomPos.x + monsterAnchorXOffset, monsterZoomPos.y, 0.5)
	global.pause_meter()
	yield(get_tree().create_timer(2), "timeout")
	monster.inhale()
	audioManager.play_sfx(screamSFX, "scream")
	yield(get_tree().create_timer(1), "timeout")
	$Tween.interpolate_property(global.player, "global_position", 
		global.player.global_position, monsterZoomPos, 1, 
		Tween.TRANS_QUART, Tween.EASE_IN)
	$Tween.interpolate_property(global.player, "scale", 
		global.player.scale, Vector2(0,0), 1, 
		Tween.TRANS_QUART, Tween.EASE_IN)
	$Tween.start()
	global.player.rotating = true
	yield(get_tree().create_timer(1), "timeout")
	global.player.hide()
	global.currentCamera.update_offset(Vector2(0, 0), 1)
	global.currentCamera.move_camera(monsterZoomPos.x, monsterZoomPos.y, 1)
	global.currentCamera.zoom_in(1)
	yield(get_tree().create_timer(1), "timeout")
	global.change_scenes("res://Maps/" + nextMap + ".tscn")
	global.level += 1
	global.nextThreshold += global.THRESHOLDADDER
	

func play_game_over():
	audioManager.stop_game_music()
	
	var monsterZoomPos = monster.cameraZoomPos.global_position
	global.player.pause()
	uiManager.hide_reticle()
	global.currentCamera.set_anchor(null)
	global.currentCamera.move_camera(monsterZoomPos.x + monsterAnchorXOffset, monsterZoomPos.y, 0.5)
	global.pause_meter()
	yield(get_tree().create_timer(2), "timeout")
	monster.roar()
	audioManager.play_sfx(screamSFX, "scream")
	uiManager.erase_HUD()
	global.change_scenes("res://Maps/gameOver.tscn")
	global.hungerMeter = 0
