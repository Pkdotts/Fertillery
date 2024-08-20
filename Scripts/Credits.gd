extends Control


func _on_Button_pressed():
	if self.visible:
		self.hide()
		uiManager.reticle.play_sfx()
		$Back.modulate = Color.white


func _on_Button_mouse_entered():
	$Back.modulate = Color.yellow
	$AudioStreamPlayer2D.play()

func _on_Button_mouse_exited():
	$Back.modulate = Color.white
