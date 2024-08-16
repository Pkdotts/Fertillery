extends Node

var reticleNode = preload("res://Nodes/Reticle.tscn")

var reticle = null

func create_reticle():
	var newReticle = reticleNode.instance()
	global.player.get_parent().add_child(newReticle)
	reticle = newReticle
