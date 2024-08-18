extends CanvasLayer

var hudNode = preload("res://Nodes/HUD.tscn")
var reticleNode = preload("res://Nodes/Reticle.tscn")
var transitionNode = preload("res://Nodes/UI/Transition.tscn")


var reticle = null
var hud = null
var transition = null


func create_HUD():
	if hud == null:
		var newHud = hudNode.instance()
		add_child(newHud)
		hud = newHud

func erase_HUD():
	if hud != null:
		hud.queue_free()
		hud = null

func create_transition():
	if transition == null:
		var newTransition = transitionNode.instance()
		add_child(newTransition)
		transition = newTransition

func erase_transition():
	if transition != null:
		transition.queue_free()
		transition = null

func create_reticle():
	var newReticle = reticleNode.instance()
	global.player.get_parent().add_child(newReticle)
	reticle = newReticle


func fade_in():
	if transition != null:
		transition.queue_free()
		transition = null
	var transitionUI = transitionNode.instance()
	add_child(transitionUI)
	transition = transitionUI
	transition.fadein()

func fade_out():
	if transition != null:
		transition.fadeout()
		transition.connect("transition_finished", self, "remove_transition")

func remove_transition():
	transition.queue_free()
	transition = null

func fade_transition():
	if transition==null:
		var transitionUI = transitionNode.instance()
		add_child(transitionUI)
		transition = transitionUI
		transition.fadein()
		yield(transition, "transition_finished")
		transition.fadeout()
		yield(transition, "transition_finished")

