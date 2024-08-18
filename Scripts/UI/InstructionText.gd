extends Control

var instructionText = {
	1: "SHIFT to Dash and pickup objects!",
	2: "Left Click to Throw!",
	3: "Throw the Driplets at the Turnip!",
	4: "Throw the Turnip into the bin!"
}

onready var label = $Label

func set_text(step):
	label.text = instructionText[step]
