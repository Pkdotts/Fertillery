extends CanvasLayer

onready var turnipsLabel = $Control/SatiationPoints/Score

func _ready():
	global.connect("updateTurnipCounter", self, "update_turnips_counter")


func update_turnips_counter():
	turnipsLabel.text = str(global.turnipsEaten)


