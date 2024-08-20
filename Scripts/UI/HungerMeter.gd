extends Control

onready var hungerBar = $HungerBar

const NORMALCOLOR = Color("ad668b")
const DANGERCOLOR = Color("ca3a51")
const TRANSLUSCENTCOLOR = Color(1, 1, 1, 0.25)


const DANGERZONE = 60
var initialSize = 0
var initialPos = 0


func _ready():
	initialSize = hungerBar.rect_size.x
	initialPos = hungerBar.rect_position.x

func _process(_delta):
	hungerBar.rect_size.x = round(initialSize - initialSize * global.hungerMeter/100)
	hungerBar.rect_position.x = round(initialPos + initialSize * global.hungerMeter/100)
	
	if global.hungerMeter > DANGERZONE:
		hungerBar.color = DANGERCOLOR
	else:
		hungerBar.color = NORMALCOLOR


func _on_Button_mouse_entered():
	$Tween.interpolate_property(self, "modulate", 
		modulate, TRANSLUSCENTCOLOR, 0.1)
	$Tween.start()

func _on_Button_mouse_exited():
	$Tween.interpolate_property(self, "modulate", 
		modulate, Color.white, 0.1)
	$Tween.start()
