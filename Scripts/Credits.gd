extends Control


func _on_Button_pressed():
	if self.visible:
		self.hide()
		uiManager.reticle.play_sfx()
