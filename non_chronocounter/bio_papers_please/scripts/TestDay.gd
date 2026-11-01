extends Node2D

# sources:
# something about glycocalyx
# something on how vaccines work
# protien names?
# immune system function

const SAVE_PATH = "user://save.sv"
const TDL_PATH = "res://data/test_day_list.txt"
const DL_PATH = "res://data/day_list"
const TIME = 30000

"""
# speech related stuff
const S_GAP = 100
const B_GAP = 70
const MAX_SPEECH = 3
@export var speech : PackedScene = null
var speech_list = []

var save = []
"""

# person is a dictionary in the fomrat of: {"name", "essay", "image", "interview"}
#var sample_person = {"name": "Bob Bobson", "essay": load("res://graphics/TextPlaceholder/TextPlaceholder.png"),"image": load("res://graphics/TextPlaceholder/TextPlaceholder.png"), "interview": null}
# ppl proecessing related
var day_list = []
var num_processed = 0 # for printing cell reports
var score = 0
var last_mistakes = 0
var cur_person = null
var placeholderrr = [$Background, "Rad blood cell"]
var cur_items = []

var hla_summoned = 0
var is_vaccine = false
var vaccine = 0

#onready stuff
@onready var text_parent = $TextParent
@onready var ABN_buttons = [$AButton, $RButton, $NButton]
@onready var I_button = $IButton
@onready var HLA_button = $HLAButton
#@onready var cur_img = $Person
@onready var timer = $Timer
@onready var cell_animation = $AnimatedSprite2D

@onready var infection = randi() % 2#(0,2) # add this once revamp type2 bacteria

func _ready():
	# experimental
	#clear_data()
	#speak(true, "test placeholder amongus")
	
	# connect buttons
	ABN_buttons[0].connect("up", next_person)
	ABN_buttons[1].connect("up", next_person)
	ABN_buttons[2].connect("up", next_person)
	I_button.connect("up", summon_hla)
	I_button.disabled = true
	HLA_button.connect("button_up", summon_hla_codes)
	HLA_button.disabled = false
	for i in range(0, 2):
		ABN_buttons[i].disabled = true
	
	# set up the timer
	#timer.connect("timeout", end_day)
	timer.wait_time = TIME
	timer.start()
	
	$AnimatedSprite2D.play("default")
	
	stopp()

# for cutscenes
func stopp(id=0):
	for child in get_children():
		if not child.name.contains("Yap") and child.name != "Timer":
			child.hide()
	$Yap.show()
	$Yap.active_scene = 0
	$Yap.load_scene(id)
	timer.set_paused(true)
func begin():
	for item in cur_items:
		text_parent.kill(item)
	cur_items = []
	cur_person = null
	for i in range(0, 2):
		ABN_buttons[i].disabled = true
	I_button.disabled = true
	ABN_buttons[2].disabled = false
	for child in get_children():
		if not child.name.contains("Yap") and child.name != "Timer":
			child.show()
	ABN_buttons[2].connect("up", next_person)
	timer.set_paused(false)

# vaccine
func vaccine_setup():
	is_vaccine = true
	vaccine = 7

# new person stuff
func call_up_person(person): # person-related
	cur_person = person
	hla_summoned = 0
	ABN_buttons[2].disabled = true
	
	#yield(animation_arrives) #goes here
	if not vaccine:
		print("not vacc summon")
		placeholderrr = text_parent.generate_glyco(cur_person)
		cur_items.append(placeholderrr[0])
	else:
		print("vacc summon")
		vaccine -= 1
		if vaccine == 0:
			#$Yap.load_scene(vaccine exlanation goes here)
			stopp(8) # idd
			return -1
		cur_person = [2, infection]
		placeholderrr = text_parent.generate_glyco([2, infection], true)
		cur_items.append(placeholderrr[0])
	
	$AnimatedSprite2D.disconnect("animation_finished", enable_buttons)
	$AnimatedSprite2D.play("red_blood_enter" if placeholderrr[1] in ["Red blood cell", "Rad blood cell", "Red blood cel1", "Muscle cell"] else "white_blood_enter")
	$AnimatedSprite2D.connect("animation_finished", enable_buttons)

func enable_buttons():
	for i in range(0,2):
		ABN_buttons[i].disabled = false
	I_button.disabled = false

func next_person(button):
	# idk why i didn't make it a void
	# returns 1 if AButton was pressed, 0 if RButton, -2 or lower if NButton (other negative values lower than -2 are experimental), -1 if error
	# 11/19 - why did I make this separate from call_up_person()?
	if button.name == "AButton" or button.name == "RButton":
		if cur_person:
			# actual results
			match cur_person[0]:
				2:
					if button.name == "RButton":
						score += 1 
					else:
						score -= 1
						last_mistakes += 1
				_:
					if button.name == "AButton":
						score += 1 
					else:
						score -= 1
						last_mistakes += 1
			num_processed += 1
			
			check_score()
			
			# generating report
			if num_processed % 6 == 0:
				text_parent.give_report()
				last_mistakes = 0
			
			# cleanup
			for item in cur_items:
				text_parent.kill(item)
			cur_items = []
			cur_person = null
			for i in range(0, 2):
				ABN_buttons[i].disabled = true
			I_button.disabled = true
			
			
			if placeholderrr[0].name != "Background":
				match button.name:
					"RButton": 
						$AnimatedSprite2D.play("red_blood_death" if placeholderrr[1] in ["Red blood cell", "Rad blood cell", "Red blood cel1", "Muscle cell"] else "white_blood_death")
					"AButton":
						$AnimatedSprite2D.play("red_blood_exit" if placeholderrr[1] in ["Red blood cell", "Rad blood cell", "Red blood cel1", "Muscle cell"] else "white_blood_exit")
				$AnimatedSprite2D.connect("animation_finished", enable_next)
	elif button.name == "NButton":
		if not cur_person:
			call_up_person(generate_random_person())
			"""
			if day_list:
				if day_list[0] != "r":
					call_up_person(day_list[0])
					day_list.erase(day_list[0])
				elif day_list[0] == "r":
					call_up_person(generate_random_person())
			else:
				call_up_person(generate_random_person())
			return -2
		return -3"""

func enable_next():
	ABN_buttons[2].disabled = false

func generate_random_person():
	return [randi_range(0,2), infection] # 2 = infection

#hla
func summon_hla(button):
	cur_items.append(text_parent.generate_hla())
	hla_summoned = 1
	I_button.disabled = true
	
	score -= 1
	check_score()

func summon_hla_codes():
	text_parent.generate_hla_codes()
	HLA_button.disabled = true
	
	score -= 2
	check_score()

# score
func check_score():
	# ending the game
	if score <= -10:
		#$Yap.load_scene(scene goes here)
		stopp(17) # idd
	if score >= 15:
		#$Yap.load_scene(scene goes here)
		stopp(25) # idd

# experimental
func clear_data():
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		dir.remove("save.sv")
	
	var save_game = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_game.store_line("0")
	save_game.store_line("-1")
	save_game.store_line("1")
	save_game.store_line("0")
	save_game.store_line("-1")
