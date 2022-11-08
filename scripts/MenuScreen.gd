extends Control


# Declare member variables here. Examples:
var currSlide = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setSlide():
	match currSlide:
		1:
			$MainMenu.visible = false
			$slide1.visible = true
			$slide2.visible = false
			$slide3.visible = false
			$ArrowLeft.visible = true
			$ArrowRight.visible = true
		2:
			$MainMenu.visible = false
			$slide1.visible = false
			$slide2.visible = true
			$slide3.visible = false
			$ArrowLeft.visible = true
			$ArrowRight.visible = true
		3:
			$MainMenu.visible = false
			$slide1.visible = false
			$slide2.visible = false
			$slide3.visible = true
			$ArrowLeft.visible = true
			$ArrowRight.visible = true
		_:
			$MainMenu.visible = true
			$slide1.visible = false
			$slide2.visible = false
			$slide3.visible = false
			$ArrowLeft.visible = false
			$ArrowRight.visible = false

func _on_StartGame_button_down():
	print("hello")
	Controller.switch2Game()


func _on_OpenRules_button_down():
	currSlide = 1
	setSlide()

func _on_LeftArrow_button_down():
	currSlide -= 1
	setSlide()

func _on_RightArrow_button_down():
	if currSlide < 3:
		currSlide += 1
	else:
		currSlide = 0
	setSlide()

func _on_OpenDifficulty_pressed():
	$MainMenu.visible = false
	$Difficulty_Screen.visible = true
	displaySettings()

func _on_BackBtn_pressed():
	$MainMenu.visible = true
	$Difficulty_Screen.visible = false

func displaySettings():
	$Difficulty_Screen/SmartChk.visible = Controller.smartBaba
	$Difficulty_Screen/SmartUnchk.visible = not Controller.smartBaba
	$Difficulty_Screen/DmgChk.visible = Controller.angryBaba
	$Difficulty_Screen/DmgUnchk.visible = not Controller.angryBaba
	$Difficulty_Screen/ShuffleChk.visible = Controller.enableShuffle
	$Difficulty_Screen/ShuffleUnchk.visible = not Controller.enableShuffle

func _on_SmartBtn_pressed():
	Controller.smartBaba = not Controller.smartBaba
	Controller.angryBaba = not Controller.angryBaba
	displaySettings()

func _on_DmgBtn_pressed():
	Controller.angryBaba = not Controller.angryBaba
	Controller.smartBaba = not Controller.smartBaba
	displaySettings()

func _on_ShuffleBtn_pressed():
	Controller.enableShuffle = not Controller.enableShuffle
	displaySettings()

func _on_DefaultBtn_pressed():
	Controller.setDefault()
	displaySettings()

func _on_YouSpin_value_changed(value):
	Controller.YouHP = $Difficulty_Screen/YouSpin.value
	displaySettings()

func _on_BabaSpin_value_changed(value):
	Controller.BabaHP = $Difficulty_Screen/BabaSpin.value
	displaySettings()
