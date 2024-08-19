extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$SatiationPointsLabel.bbcode_text = var2str(global.turnipCount)
	if global.turnipCount > global.highScore:
		global.highScore = global.turnipCount 
		$HighScoreLabel.bbcode_text = "[rainbow]" + var2str(global.highScore)
	else:
		$HighScoreLabel.bbcode_text = var2str(global.highScore)
	$TimeSurvivedLabel.bbcode_text = global.get_time()
	uiManager.show_reticle()
	uiManager.reticle.set_mode(1)

func _on_TitleButton_pressed():
	global.change_scenes("res://Maps/TutorialFarm.tscn")


func _on_TitleButton_mouse_entered():
	$TitleScreenButton.modulate = Color.yellow

func _on_TitleButton_mouse_exited():
	$TitleScreenButton.modulate = Color.white
