extends Control

func _ready():
	$SatiationPointsLabel.bbcode_text = var2str(global.turnipsEaten)
	if global.turnipsEaten > global.highScore:
		global.highScore = global.turnipsEaten 
		$HighScoreLabel.bbcode_text = "[rainbow]" + var2str(global.highScore)
	else:
		$HighScoreLabel.bbcode_text = var2str(global.highScore)
	$TimeSurvivedLabel.bbcode_text = global.get_time()
	uiManager.show_reticle()
	uiManager.reticle.set_mode(1)

func _on_TitleButton_pressed():
	global.level = 0
	global.change_scenes("res://Maps/TutorialFarm.tscn")
	$AudioStreamPlayer.play()

func _on_TitleButton_mouse_entered():
	$TitleScreenButton.modulate = Color.yellow
	$AudioStreamPlayer2.play()

func _on_TitleButton_mouse_exited():
	$TitleScreenButton.modulate = Color.white
