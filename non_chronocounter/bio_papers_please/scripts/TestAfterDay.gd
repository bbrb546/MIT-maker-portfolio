extends Node2D

const SAVE_PATH = "user://save.sv"
const MONEY_PER_ARP =  5 # money per person accepted/rejected

var gain = 0

# stored in saves
var savings = 0
var family_statuses = -1 # each number will represent a different status of the family, key tbd
var day_num = -1
var ARP = -1 # accepted/rejected people
var quality = -1
var special_items = []
# umbrella variable - hopefully pointer, but even if it isn't ill code it so it doesn't matter
var save = [savings, family_statuses, day_num, ARP, quality]

@onready var gain_label = $Gain
@onready var money_display_label = $MoneyDisplay
@onready var continue_button = $ContinueButton

# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(SAVE_PATH):
		# process data
		var save_game = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var index = 0
		
		while save_game.get_position() < save_game.get_length():
			var cur_line = save_game.get_line()
			
			save[index] = int(cur_line)
			index += 1
		
		# update data
		gain = save[3] * MONEY_PER_ARP
		if save[3]: # money gain
			save[0] += gain
			save[3] = 0
		save[2] += 1 # move up the day
		
		# interact with ui/actual visible stuff
		gain_label.text = "+" + str(gain)
		money_display_label.text = "You have " + str(save[0]) + " dollars!"
		continue_button.connect("button_up", end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func end():
	# store hte values back into the save file
	# delete the original one
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		dir.remove("save.sv")
	
	var save_game = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	for value in save:
		save_game.store_line(str(value))
	
	# and swap the scene
	# note: doesn't work
	get_tree().change_scene_to_file("res://scenes/game_scenes/TestDay.tscn")
