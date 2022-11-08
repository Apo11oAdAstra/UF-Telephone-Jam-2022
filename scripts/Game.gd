extends Node2D
var Tile = load("res://scripts/Tile.gd")
var Person = load("res://scripts/Person.gd")


# Variables for graphics
var youHPpos
var babaHPpos
# Variables for handling the player input
var entered = false
var createSentence = false
var coordList = []
var babaCordLists = []
var board = []
var turn = true
var maxTime = 15
var paused = false
var gameover = false
# Board Gen Variable
var state = 0
var rng = RandomNumberGenerator.new()
var currentTile
var startCol 
var startRow 
# You variables
var you = null
var youNext = 0
# Baba Variables
var baba = null
var babaNext = 0
var stack = []
var smartState = 0
# Variables for compiling sentences
enum WORD {YOU, BABA, IS, AND, HEAL, BLOCK, NEXT, RAIN, MELT, BOLT, DEAD}
var current = null
var wordList = []
var nouns = [WORD.YOU, WORD.BABA]
var verbs = [WORD.IS, WORD.AND]
var modifiers = [WORD.HEAL, WORD.BLOCK, WORD.NEXT, WORD.RAIN, WORD.MELT, WORD.BOLT, WORD.DEAD]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	startGame()
	youHPpos = $YouHP.rect_global_position
	babaHPpos = $BabaHP.rect_global_position
	

func startGame():
	rng.randomize()
	you = Person.new(Controller.YouHP)
	baba = Person.new(Controller.BabaHP)
	startCol = rng.randi_range(0, 12)
	startRow = rng.randi_range(0,4)
	board.clear()
	createBoard(false)
	displayBoard()
	$Timer.start(15)
	$Shuffle.visible = Controller.enableShuffle
	$ShuffleImg.visible = Controller.enableShuffle
	
	# set tile colors
	$TileBorder.set_modulate(Color(1,1,1))
	$Board/Tiles.tile_set.tile_set_modulate(00, Color("eb91ca")) # AND
	$Board/Tiles.tile_set.tile_set_modulate(01, Color("d9396a")) # BABA
	$Board/Tiles.tile_set.tile_set_modulate(02, Color("000000")) # BLANK
	$Board/Tiles.tile_set.tile_set_modulate(03, Color("c3c3c3")) # BLOCK
	$Board/Tiles.tile_set.tile_set_modulate(04, Color("8e5e9c")) # BOLT
	$Board/Tiles.tile_set.tile_set_modulate(05, Color("82261c")) # DEAD
	$Board/Tiles.tile_set.tile_set_modulate(06, Color("a5b13f")) # HEAL
	$Board/Tiles.tile_set.tile_set_modulate(07, Color("ede285")) # IS
	$Board/Tiles.tile_set.tile_set_modulate(08, Color("e5533b")) # MELT
	$Board/Tiles.tile_set.tile_set_modulate(09, Color("83c8e5")) # NEXT
	$Board/Tiles.tile_set.tile_set_modulate(10, Color("5f9dd1")) # RAIN
	$Board/Tiles.tile_set.tile_set_modulate(11, Color("26c695")) # YOU

func createBoard(part : bool):
	if !part:
		for r in range(0, 13):
				board.append([])
				for c in range (0, 5):
					board[r].append(Tile.new())
	board[startCol][startRow].setWord(genToken())
	board[startCol][startRow].visited = true
	var stack = [[startCol, startRow]]
	var currentTile = stack[0]
	while(!stack.empty()):
		var neighbors = getNeighbors(currentTile)
		var hasVisitors = false
		for coord in neighbors:
			if !board[coord[0]][coord[1]].visited and not hasVisitors:
				board[coord[0]][coord[1]].setWord(genToken())
				board[coord[0]][coord[1]].visited = true
				stack.push_back(coord)
				currentTile = coord
				hasVisitors = true
		if !hasVisitors:
			currentTile = stack.pop_back()

func genToken():
	if state == 0:
		state = 1
		return nouns[rng.randi_range(0, 1)]
	elif state == 1:
		state = 2
		return WORD.IS
	elif state == 2:
		state = 3
		return getModif()
	elif state == 3:
		if notfail():
			state = 4
			return WORD.AND
		else:
			state = 1
			return nouns[rng.randi_range(0, 1)]
	elif state == 4:
		state = 0
		return getModif()

func notfail():
	var roll = randf()
	var chance = .5
	return roll <= chance

func getModif():
	var roll = randf()
	var pool = 0.9995
	var options = 6
	if   roll <= pool/options*1:
		return WORD.HEAL
	elif roll <= pool/options*2:
		return WORD.BLOCK
	elif roll <= pool/options*3:
		return WORD.NEXT
	elif roll <= pool/options*4:
		return WORD.RAIN
	elif roll <= pool/options*5:
		return WORD.MELT
	elif roll <= pool/options*6:
		return WORD.BOLT
	else:
		return WORD.DEAD

func getNeighbors(coords):
	if coords[0] == 0:
		if coords[1] == 0:
			return [[0,1], [1,0]]
		elif coords[1] == 4:
			return [[0,3], [1,4]]
		else:
			return [[1,coords[1]], [coords[0], coords[1]-1], [coords[0], coords[1]+1]]
	elif coords[0] == 12:
		if coords[1] == 0:
			return [[12,1], [11,0]]
		elif coords[1] == 4:
			return [[12,3], [11,4]]
		else:
			return [[11,coords[1]], [coords[0], coords[1]-1], [coords[0], coords[1]+1]]
	elif coords[1] == 0:
			return [[coords[0]-1,0], [coords[0]+1, 0], [coords[0], 1]]
	elif coords[1] == 4:
			return [[coords[0]-1,4], [coords[0]+1, 4], [coords[0], 3]]
	else:
		return [[coords[0]-1, coords[1]], [coords[0]+1, coords[1]], [coords[0], coords[1]-1], [coords[0], coords[1]+1]]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# update Progress Bars
	$BabaHP.value = baba.currHP / baba.maxHP * 100
	$YouHP.value = you.currHP / you.maxHP * 100
	$TimerBar.value = $Timer.time_left / 15 * 100
	$BabaStats.text = "ARMOR: %.1f\nNEXTS: %d\nHP: %.1f / %d\nDMG: %d" % [baba.numBlocks, babaNext, baba.currHP, baba.maxHP, baba.baseDMG]
	$YouStats.text = "ARMOR: %.1f\nNEXTS: %d\nHP: %.1f / %d" % [you.numBlocks, youNext, you.currHP, you.maxHP]
	var t = (1 - ($Timer.time_left / 15))
	for i in range(0, 12):
		var rx = rand_range(-1, 1) * pow(10, t-1) * 1
		var ry = rand_range(-1, 1) * pow(10, t-1) * 1
		$Board/Tiles.tile_set.tile_set_texture_offset(i, Vector2(rx, ry))
	
	# shake HP bars
	$YouHP.rect_global_position = youHPpos + Vector2(rand_range(-1, 1) * $youHPshake.time_left, rand_range(-1, 1) * $youHPshake.time_left) * 5
	$BabaHP.rect_global_position = babaHPpos + Vector2(rand_range(-1, 1) * $babaHPshake.time_left, rand_range(-1, 1) * $babaHPshake.time_left) * 5
	
	if createSentence:
		var pos = $Board/Tiles.world_to_map(get_viewport().get_mouse_position() - $Board.get_global_position())
		# Check to see if you're outside the bounding box
		if pos.x < 0 or pos.x > 13-1 or pos.y < 0 or pos.y > 5-1:
			pass
		# check if you have moved to a different tile
		elif pos != coordList.back():
			# check if its in the list
			if coordList.find(pos) > -1:
				coordList.resize(coordList.find(pos))
			# else try to add it to the list
			else:
				# always add first term
				if coordList.size() == 0:
					coordList.push_back(pos)
				else:
					# check if neighbors (no further than 1 on a single axis
					var diff = pos - coordList[-1];
					if (abs(diff.x) == 1 and diff.y == 0) or (diff.x == 0 and abs(diff.y) == 1):
						coordList.push_back(pos)
			# connectors changed so redraw
			displayConnectors()
	if !turn:
		if Controller.smartBaba:
			if smartState == 0 :
				checkForMoves()
				pickBabaMove()
				displayConnectors()
				$BabaChoice.start()
				smartState = 1
			elif smartState == 1:
				if $BabaChoice.is_stopped():
					smartState = 2
			else:
				babaCordLists.clear()
				wordList = genWordList(coordList)
				sentenceCheck()
				smartState = 0
		elif Controller.angryBaba:
			you.takeDMG(baba.baseDMG)
			$youHPshake.start()
			while(babaNext > 0):
				you.takeDMG(baba.baseDMG)
				$youHPshake.start()
				babaNext -= 1
			turn = true
			$Timer.start(getTimerVal())
			maxTime = getTimerVal()
			
		checkGameOver()

func displayConnectors():
	# clear all cells
	for x in range(0, 13):
		for y in range(0, 5):
			$Board/Connect_C2E.set_cell(x,y,10)
			$Board/Connect_E2C.set_cell(x,y,10)
	
	# draw connections over cells
	if coordList.size() == 0:
		pass
	elif coordList.size() == 1:
		# First is always center-to-edge (doesnt matter in this case)
		$Board/Connect_C2E.set_cellv(coordList[0],11)
	else:
		# First node is always center-to-edge
		match (coordList[0]-coordList[1]):
			Vector2(0,1): # up
				$Board/Connect_C2E.set_cellv(coordList[0],0)
			Vector2(0,-1): # down
				$Board/Connect_C2E.set_cellv(coordList[0],1)
			Vector2(1,0): # left
				$Board/Connect_C2E.set_cellv(coordList[0],2)
			Vector2(-1,0): #right
				$Board/Connect_C2E.set_cellv(coordList[0],3)
		# Middle nodes need both
		for i in range(1, coordList.size()-1):
			var E2C = coordList[i]-coordList[i-1]
			var C2E = coordList[i]-coordList[i+1]
			match C2E:
				Vector2(0,1): # up
					$Board/Connect_C2E.set_cellv(coordList[i],0)
				Vector2(0,-1): # down
					$Board/Connect_C2E.set_cellv(coordList[i],1)
				Vector2(1,0): # left
					$Board/Connect_C2E.set_cellv(coordList[i],2)
				Vector2(-1,0): #right
					$Board/Connect_C2E.set_cellv(coordList[i],3)
			match E2C:
				Vector2(0,1): # up
					$Board/Connect_E2C.set_cellv(coordList[i],0)
				Vector2(0,-1): # down
					$Board/Connect_E2C.set_cellv(coordList[i],1)
				Vector2(1,0): # left
					$Board/Connect_E2C.set_cellv(coordList[i],2)
				Vector2(-1,0): #right
					$Board/Connect_E2C.set_cellv(coordList[i],3)
			
		# Last node is edge-to-center
		match (coordList[-1]-coordList[-2]):
			Vector2(0,1): # up
				$Board/Connect_E2C.set_cellv(coordList[-1],0)
			Vector2(0,-1): # down
				$Board/Connect_E2C.set_cellv(coordList[-1],1)
			Vector2(1,0): # left
				$Board/Connect_E2C.set_cellv(coordList[-1],2)
			Vector2(-1,0): #right
				$Board/Connect_E2C.set_cellv(coordList[-1],3)
	

func displayBoard():
	for x in range(0, board.size()):
		for y in range(0, board[0].size()):
			$Board/Tiles.set_cell(x,y,board[x][y].toInt())

func _on_Board_mouse_entered():
	entered = true

func _on_Board_mouse_exited():
	entered = false

func _on_Timer_timeout():
	if turn:
		if youNext > 0:
			youNext -= 1
			$Timer.start(getTimerVal())
		else:
			turn = !turn
	else:
		if babaNext > 0:
			babaNext -= 1
			$Timer.start(getTimerVal())
		else:
			turn = !turn

func _on_Pause_button_down():
	paused = true
	$PauseMenu.visible = true
	$Timer.paused = true

func _on_Shuffle_button_down():
	board.clear()
	createBoard(false)
	displayBoard()
	
	you.takeDMG(you.maxHP / 10)
	checkGameOver()
	

func _input(event):
	if gameover:
		if event is InputEventMouseButton and event.is_action_pressed("ui_mouse"):
			Controller.switch2Menu()
			gameover = false
			$LoseScreen.visible = false
			$WinScreen.visible = false
			$Timer.paused = false
			startGame()
	elif paused:
		if event is InputEventMouseButton and event.is_action_pressed("ui_mouse"):
			paused = false
			$PauseMenu.visible = false
			$Timer.paused = false
	elif turn:
		# check to see if person let go, which means they finished their sentence
		if event is InputEventMouseButton and event.is_action_released("ui_mouse"):
			createSentence = false
			wordList = genWordList(coordList)
			sentenceCheck()
			
		# check to see if they're within the board
		if entered and event is InputEventMouseButton and event.is_action_pressed("ui_mouse"):
			createSentence = true
	


func sentenceCheck():
	var doWhile = true
	var ret = 0
	var dmgBonus = 1
	var prev = null
	var noun = null
	var blocks = 0;
	var heal = 1;
		
	current = wordList.pop_front()
	if nouns.has(current):
		noun = current
		current = wordList.pop_front()
		if current == WORD.IS:
			current = wordList.pop_front()
			if modifiers.has(current):
				ret = 3
				while doWhile or (not wordList.empty() and wordList.front() == WORD.AND):
					if(doWhile):
						doWhile = false
					else:
						current = wordList.pop_front()
						current = wordList.pop_front()
						ret += 2
					if modifiers.has(current):
						if current in [WORD.RAIN, WORD.MELT, WORD.BOLT]:
							if prev != null and prev != current:
								dmgBonus += calcBonus(prev, current)
								prev = null
							else:
								prev = current
								dmgBonus += .2
						elif current == WORD.HEAL:
							heal = -1
						elif current == WORD.BLOCK:
							blocks += 1
						elif current == WORD.NEXT:
							if noun == WORD.YOU:
								youNext += 1
							else:
								babaNext += 1
						else:
							getNounPlayer(noun).setDead()
					else:
						clearCoordList(false)
						return
	if not wordList.empty() or ret == 0:
		clearCoordList(false)
	else:
		var total = ret*dmgBonus*heal
		getNounPlayer(noun).takeDMG(total)
		getNounPlayer(noun).addBlocks(blocks)
		clearCoordList(true)
		checkForMoves()
		checkGameOver()
		
		if noun == WORD.YOU:
			$youHPshake.start()
		elif noun == WORD.BABA:
			$babaHPshake.start()

func checkForMoves():
	stack.clear()
	for c in range(0,13):
		for r in range(0,5):
			if nouns.has(board[c][r].word):
				stack.push_back([c, r])
				var neighbors = getNeighbors([c, r])
				for coords in neighbors:
					if board[coords[0]][coords[1]].word == WORD.IS:
						stack.push_back(coords)
						var neighborsNew = getNeighbors([coords[0], coords[1]])
						for coordsNew in neighborsNew:
							if modifiers.has(board[coordsNew[0]][coordsNew[1]].word):
								stack.push_back(coordsNew)
								if(!turn):
									getBonusTiles()
								else:
									return
								stack.pop_back()
						stack.pop_back()
				stack.pop_back()
	if(turn or babaCordLists.empty()):
		board.clear()
		createBoard(false)
		displayBoard()

func getBonusTiles():
	var current = stack.back()
	var neighbors = getNeighbors(current)
	for coords in neighbors:
		if (board[coords[0]][coords[1]].word == WORD.AND and !stack.has(coords)):
			current = coords
			stack.push_back(current)
			var neighborsNew = getNeighbors(current)
			for coordsNew in neighborsNew:
				if modifiers.has(board[coordsNew[0]][coordsNew[1]].word) and !stack.has(coordsNew):
					stack.push_back(coordsNew)
					getBonusTiles()
					stack.pop_back()
			stack.pop_back()
	babaCordLists.append(stack.duplicate(true))

func pickBabaMove():
	var sentence = babaCordLists[0]
	var prior = sentencePriority(sentence)
	for i in range(1, babaCordLists.size()):
		var priorNew = sentencePriority(babaCordLists[i])
		if priorNew < prior:
			sentence = babaCordLists[i]
			prior = priorNew
		elif priorNew == prior:
			match(prior):
				0:
					if babaCordLists[i].size() > sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				1:
					if babaCordLists[i].size() < sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				2:
					if babaCordLists[i].size() > sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				3:
					if babaCordLists[i].size() < sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				4:
					if babaCordLists[i].size() > sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				5:
					if babaCordLists[i].size() < sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				6:
					if babaCordLists[i].size() > sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				7:
					if babaCordLists[i].size() < sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				8:
					if babaCordLists[i].size() < sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
				9:
					if babaCordLists[i].size() > sentence.size():
						sentence = babaCordLists[i]
						prior = priorNew
	coordList = Array2Vector(sentence)

func sentencePriority(sentence):
	var words = genWordList(Array2Vector(sentence))
	if words[0] == WORD.BABA:
		if words.has(WORD.NEXT) and words.has(WORD.HEAL):
			return 0
		elif words.has(WORD.NEXT):
			return 1
		elif words.has(WORD.HEAL):
			return 2
		elif words.has(WORD.BLOCK):
			return 3
		else:
			return 8
	else:
		if words.has(WORD.NEXT) and words.has(WORD.HEAL):
			return 7
		elif words.has(WORD.NEXT):
			return 6
		elif words.has(WORD.HEAL):
			return 5
		elif words.has(WORD.BLOCK):
			return 9
		else:
			return 4

func checkGameOver():
	# modulate the board
	var hp = (you.currHP / you.maxHP)
	
	if hp <= 0.30:
		# set tile colors
		$TileBorder.set_modulate(Color(1 - hp, hp, hp))
		var coloredit = Color(1 - hp, hp, hp, 0.5)
		$Board/Tiles.tile_set.tile_set_modulate(00, Color("eb91ca").blend(coloredit)) # AND
		$Board/Tiles.tile_set.tile_set_modulate(01, Color("d9396a").blend(coloredit)) # BABA
		$Board/Tiles.tile_set.tile_set_modulate(02, Color("000000").blend(coloredit)) # BLANK
		$Board/Tiles.tile_set.tile_set_modulate(03, Color("c3c3c3").blend(coloredit)) # BLOCK
		$Board/Tiles.tile_set.tile_set_modulate(04, Color("8e5e9c").blend(coloredit)) # BOLT
		$Board/Tiles.tile_set.tile_set_modulate(05, Color("82261c").blend(coloredit)) # DEAD
		$Board/Tiles.tile_set.tile_set_modulate(06, Color("a5b13f").blend(coloredit)) # HEAL
		$Board/Tiles.tile_set.tile_set_modulate(07, Color("ede285").blend(coloredit)) # IS
		$Board/Tiles.tile_set.tile_set_modulate(08, Color("e5533b").blend(coloredit)) # MELT
		$Board/Tiles.tile_set.tile_set_modulate(09, Color("83c8e5").blend(coloredit)) # NEXT
		$Board/Tiles.tile_set.tile_set_modulate(10, Color("5f9dd1").blend(coloredit)) # RAIN
		$Board/Tiles.tile_set.tile_set_modulate(11, Color("26c695").blend(coloredit)) # YOU
	
	# check for win/lose
	if you.isDead:
		$LoseScreen.visible = true
		gameover = true
		$Timer.paused = true
	if baba.isDead:
		$WinScreen.visible = true
		gameover = true
		$Timer.paused = true

# Calculate Dmg Bonus
func calcBonus(first, second):
	var list = [first , second]
	if list in [[WORD.RAIN, WORD.MELT], [WORD.MELT, WORD.RAIN]]:
		return .6
	else:
		return .4

# Get Current Player Object
func getNounPlayer(noun):
	if noun == WORD.YOU:
		return you
	return baba

func getTimerVal():
	if baba.currHP > .5*baba.maxHP:
		return 15
	elif baba.currHP > .25*baba.maxHP:
		return 10
	else:
		return 5
		
func Array2Vector(coords):
	var ret = []
	for i in range(0, coords.size()):
		ret.append(Vector2(coords[i][0], coords[i][1]))
	return ret

func genWordList(coords):
	var ret = []
	for i in range(0, coords.size()):
		var pos = coords[i]
		ret.append(board[pos.x][pos.y].word)
	return ret
	
func clearCoordList(valid : bool):
	if(valid):
		startCol = coordList[0].x
		startRow = coordList[0].y
		for i in range(0, coordList.size()):
			var pos = coordList[i]
			board[pos.x][pos.y].visited = false
		createBoard(true)
	coordList.clear()
	displayBoard()
	displayConnectors()

