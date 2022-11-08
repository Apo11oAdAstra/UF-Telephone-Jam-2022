extends Node

var smartBaba
var angryBaba
var enableShuffle
var BabaHP
var YouHP

# Called when the node enters the scene tree for the first time.
func _ready():
	setDefault()

func setDefault():
	smartBaba = false
	angryBaba = true
	enableShuffle = false
	BabaHP = 100
	YouHP = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func switch2Game():
	get_tree().change_scene("res://levels/Game.tscn")
	
func switch2Menu():
	get_tree().change_scene("res://levels/MenuScreen.tscn")
