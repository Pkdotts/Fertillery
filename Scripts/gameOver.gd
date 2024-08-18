extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Results.bbcode_text = "[center]Total Turnips fed - " + var2str(global.turnipCount) + "[/center]"
	if global.turnipCount > global.highScore:
		$HighScore.bbcode_text = "[center][wave][rainbow]NEW THigh score - " + var2str(global.turnipCount)
		global.highScore = global.turnipCount 
	else:
		$HighScore.bbcode_text = "[center]THigh score - " + var2str(global.highScore) + "[/center]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	global.change_scenes("res://Maps/Farm.tscn")


func _on_Button2_pressed():
	global.change_scenes("res://Maps/TitleScreen.tscn")
