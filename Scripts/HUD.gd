extends CanvasLayer

onready var turnipsLabel = $Control/TurnipsFed/Score
onready var hungerLabel = $Control/Hunger/Label

func _ready():
	global.connect("updateTurnipCounter", self, "update_turnips_counter")

func _process(delta):
	hungerLabel.text = str(int(global.hungerMeter))

func update_turnips_counter():
	turnipsLabel.text = str(global.turnipsEaten)


