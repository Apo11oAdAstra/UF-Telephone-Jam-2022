extends Node

# Declare member variables here. Examples:
var currHP : float
var maxHP : float
var numBlocks : float
var isDead : bool
var baseDMG : float

# Constructor
func _init(imaxHP : float):
	maxHP = imaxHP
	currHP = imaxHP
	numBlocks = 0
	isDead = false
	baseDMG = 6

func takeDMG(dmg : float):
	if(dmg > 0):
		var totalDMG = dmg - numBlocks
		if totalDMG > 0:
			currHP -= totalDMG
		if Controller.angryBaba:
			baseDMG += 1
	else:
		currHP -= dmg
		if(currHP > maxHP):
			currHP = maxHP
		if Controller.angryBaba and baseDMG > 6:
			baseDMG -= 1
	
	if currHP <= 0:
		setDead()
	
func addBlocks(block: float):
	numBlocks += (.5 * block)

func setDead():
	isDead = true
	currHP = 0
