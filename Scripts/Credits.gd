extends Control


func _on_Button_pressed():
	if self.visible:
		self.hide()
		uiManager.reticle.play_sfx()


func _on_Button_mouse_entered():
	$Back.modulate = Color.yellow

func _on_Button_mouse_exited():
	$Back.modulate = Color.white
