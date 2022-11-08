extends Node

# Declare member variables here. Examples:
enum WORD {YOU, BABA, IS, AND, HEAL, BLOCK, NEXT, RAIN, MELT, BOLT, DEAD}
var word
var visited = false

# Constructor
func _init():
	pass

func roll():
	var roll = randf()
	if roll <= 0.33:
		if randf() <= 0.5:
			word = WORD.IS
		else:
			word = WORD.AND
	elif roll <= 0.66:
		if randf() <= 0.5:
			word = WORD.YOU
		else:
			word = WORD.BABA
	else:
		roll = randf()
		var pool = 0.99
		var options = 6
		if   roll <= pool/options*1:
			word = WORD.HEAL
		elif roll <= pool/options*2:
			word = WORD.BLOCK
		elif roll <= pool/options*3:
			word = WORD.NEXT
		elif roll <= pool/options*4:
			word = WORD.RAIN
		elif roll <= pool/options*5:
			word = WORD.MELT
		elif roll <= pool/options*6:
			word = WORD.BOLT
		else:
			word = WORD.DEAD

func setWord(token):
	word = token
	
func toInt():
	match word:
		WORD.AND:
			return 0
		WORD.BABA:
			return 1
		WORD.BLOCK:
			return 3
		WORD.BOLT:
			return 4
		WORD.DEAD:
			return 5
		WORD.HEAL:
			return 6
		WORD.IS: 
			return 7
		WORD.MELT:
			return 8
		WORD.NEXT:
			return 9
		WORD.RAIN:
			return 10
		WORD.YOU:
			return 11
		_:
			return 2 #blank

func toString():
	match word:
		WORD.AND:
			return "AND"
		WORD.BABA:
			return "BABA"
		WORD.BLOCK:
			return "BLOCK"
		WORD.BOLT:
			return "BOLT"
		WORD.DEAD:
			return "DEAD"
		WORD.HEAL:
			return "HEAL"
		WORD.IS: 
			return "IS"
		WORD.MELT:
			return "MELT"
		WORD.NEXT:
			return "NEXT"
		WORD.RAIN:
			return "RAIN"
		WORD.YOU:
			return "YOU"
		_:
			return "why is it this"
