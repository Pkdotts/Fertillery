extends Control

signal pressed_start

var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#if global.turnipCount == 0:
	#	$Results.hide()
	#else:
	$Results.show()
	$Results.text = var2str(global.turnipCount)
	uiManager.reticle.set_mode(1)


func _on_Button_pressed():
	if enabled:
		emit_signal("pressed_start")
		hide()
		uiManager.reticle.play_sfx()

func _on_Button2_pressed():
	if enabled:
		$Credits.show()
		uiManager.reticle.play_sfx()

func hide():
	enabled = false
	$Tween.interpolate_property(self, "rect_position:y",
		rect_position.y, rect_position.y - 400, 0.5,Tween.TRANS_QUART, Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	hide()
