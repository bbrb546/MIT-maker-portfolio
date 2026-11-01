extends Node2D

const NORM_TYPE = ["Red blood cell","Red blood cell","Red blood cell", "White blood cell", "Stem cell"]
const NORM_REASON = {"Red blood cell" : ["Transporting oxygen", "Transporting CO2"], "White blood cell": ["Detecting bacteria", "Detecting viruses"], "Stem cell":["Differentiating", "Idle"]}
const NORM_ORIGIN = ["Left lung", "Right lung", "Heart", "Liver", "Small intestine", "Stomach"]
const NORM_STAGE = {"Red blood cell" : ["Mature"], "White blood cell": ["Mature"], "Stem cell":["Growth 1", "Growth 1","Growth 2", "Synthesis"]}

const INF_LTEXT = [["PROFESSION", "TIDES", "TEIPE"], ["RESON", "REESoN", "REEZON"],["LOCATES", "Location", "L0CATIoN"],["5JAGE", "STaGe", "STAAGS"]]
const INF_TITLE = ["GLYC0CALYX", "GLICOCALYX", "GLYCOCELYX", "GLYCOCALCK"]
const INF_RTEXT = [["Stem call", "Rad blood cell", "Muscle cell", "Whiteblood cell", "Red blood cel1"], ["Transporting iron", "Transporting CO", "Undergoing meiosis"], ["Left liver", "Middle Lung", "Nephridia"], ["Building", "Erythropoiesis", "Retired"]]

const JOB_STR = """{Job}

{Reason}

{Origin}

{Stage}
"""
const CAP_STR = """{TYPE}

{REASON}

{ORIGIN}

{STAGE}
"""

# norm, inf
var hla = [["Z8T5M2L9X1C7P", "B3Q7K2W9Y5N4T", "X1D9T5M7P2K8L", "C6Q8Y2B7N5X9T", "P4M9T7K2L8X1D", "N7Y5X2B9T8K3Q", "L2M8T5P9X7K1D", "Y9K7B2Q5T8M3X", "D5X1M9T7K8L2P", "T2Q8B7Y9X5K3M", "M9X7P2T5K8L1D", "K7Y2B8X9T5M3Q"],["Z8TSM2L9XlC8P", "B5Q7K2W8Y5M4T", "XlD9T5N7B2K8L", "C6Q9U2B7M5X9T", "P4W9T7Z2L8X2D", "N7U5X3B9T8K3P", "L2M9T2P9X7K10", "Y9K2B2Q5Z8M5X", "D6X1N9T7K8L2B", "T2Q887Y9QSK3M", "M9X7P3TSK8LlD", "K6Y288X9T5MSQ"]]

# scenes used
@export var text_scene : PackedScene = null
@export var glyco : PackedScene = null
@export var HLA : PackedScene = null
@export var cell_report : PackedScene = null

# drawing-related variables
var max_layer = 0 # ui ranges from 1 - infinity, background is 0
var texts = []
var tixt = ["Type", "Reason", "Origin", "Stage"]

# managing "calls"
var top_node = null
var o_mouse_pos = Vector2()
var cur_mouse_pos = Vector2()

# for bounds on ui movement 
# given the TextParent is located at the center of the "bounds", and the bounds are a rectangle, x/y_bounds are the half x or y
var x_bounds = 362
var y_bounds = 291

var cur_person = null

@onready var inf_hla = []
@onready var norm_hla = []

func _ready():
	# experimental
	add_text($CellReport)
	# finding the hla codes we use, not actually that random...
	var seed_nums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
	seed_nums.shuffle()
	for number in seed_nums.slice(0, 6):
		inf_hla.append(hla[1][number])
		norm_hla.append(hla[0][number])

func _process(delta):
	# manage paper movement
	if top_node:
		# generate width, length, etc
		var node_width = load(top_node.texture_normal.load_path).get_width()
		var node_height = load(top_node.texture_normal.load_path).get_height()
		var node_x = top_node.position.x
		var node_y = top_node.position.y
		
		# check mouse position
		cur_mouse_pos = get_viewport().get_mouse_position() # get the actual calls later
		
		# check to see if paper is not on boundary
		if cur_mouse_pos - o_mouse_pos:
			# move
			if node_x > -x_bounds: # restricting movement when not within bounds
				if (cur_mouse_pos - o_mouse_pos).x < 0:
					top_node.position.x += (cur_mouse_pos - o_mouse_pos).x
			if node_x + node_width < x_bounds:
				if (cur_mouse_pos - o_mouse_pos).x > 0:
					top_node.position.x += (cur_mouse_pos - o_mouse_pos).x
			if node_y + node_height > -y_bounds: # restricting movement when not within bounds
				if (cur_mouse_pos - o_mouse_pos).y < 0:
					top_node.position.y += (cur_mouse_pos - o_mouse_pos).y
			if node_y < y_bounds:
				if (cur_mouse_pos - o_mouse_pos).y > 0:
					top_node.position.y += (cur_mouse_pos - o_mouse_pos).y
				
				o_mouse_pos = cur_mouse_pos
		
		if not (x_bounds == -1 and y_bounds == -1):
			# note to self: make more efficient later, but works for now
			# assuming the position returns the top-left corner of the texture
			if node_x < -x_bounds: # shifting it a bit so it can still move, and aligning it with the bounds
				top_node.position.x = -x_bounds 
			if node_x + node_width > x_bounds:
				top_node.position.x = x_bounds  - node_width
			if node_y < -y_bounds:
				top_node.position.y = -y_bounds 
			if node_y + node_height > y_bounds:
				top_node.position.y = y_bounds - node_height
			
			# check to see if mouse is within bounds too
			if cur_mouse_pos.x - self.position.x < -x_bounds or cur_mouse_pos.x - self.position.x > x_bounds or cur_mouse_pos.y - self.position.y < -y_bounds or cur_mouse_pos.y - self.position.y > y_bounds:
				if node_x < -x_bounds: # shifting it a bit so it can still move, and aligning it with the bounds
					top_node.position.x = -x_bounds 
				if node_x + node_width > x_bounds:
					top_node.position.x = x_bounds  - node_width
				if node_y < -y_bounds:
					top_node.position.y = -y_bounds 
				if node_y + node_height > y_bounds:
					top_node.position.y = y_bounds - node_height
				untop(top_node)
	pass


# high-level functions
func generate_glyco(prson, vaccine=false): # prson[0] = cell or bacteria, prson[1] = infection seed
	cur_person = prson
	var new_text = glyco.instantiate()
	add_text(new_text)
	
	# generating the text
	tixt = ["Type", "Reason", "Origin", "Stage"]
	tixt[0] = ranel(NORM_TYPE)
	tixt = [tixt[0], ranel(NORM_REASON[tixt[0]]), ranel(NORM_ORIGIN), ranel(NORM_STAGE[tixt[0]])]
	new_text.get_node("RightText").text = JOB_STR.format({"Job": tixt[0] , "Reason":tixt[1], "Origin":tixt[2],"Stage":tixt[3]})
	
	# changing it if infected
	if prson[0] == 2:
		# generate random seeds
		var seeds = [randi() % 4, -1, -1]
		var osdjifp = randi() % 3
		seeds[1] = osdjifp + (1 if osdjifp >= seeds[0] else 0)
		
		match prson[1]:
			0: # errors in the left texts/descriptors
				seeds = [randi() % 5, -1, -1]
				osdjifp = randi() % 3
				seeds[1] = osdjifp + (1 if osdjifp >= seeds[0] else 0)
				if vaccine: # vaccine exception
					var taxt = [ranel(INF_LTEXT[0]),ranel(INF_LTEXT[1]),ranel(INF_LTEXT[2]),ranel(INF_LTEXT[3])]
					new_text.get_node("Title").text = ranel(INF_TITLE)
					new_text.get_node("LeftText").text = CAP_STR.format({"TYPE": taxt[0] , "REASON":taxt[1], "ORIGIN":taxt[2],"STAGE":taxt[3]})
					
					return [new_text, tixt[0]]
				var taxt = ["TYPE", "REASON", "LOCATION", "STAGE"]
				if seeds[0] != 4:
					taxt[seeds[0]] = ranel(INF_LTEXT[seeds[0]])
					taxt[seeds[1]] = ranel(INF_LTEXT[seeds[1]])
					new_text.get_node("LeftText").text = CAP_STR.format({"TYPE": taxt[0] , "REASON":taxt[1], "ORIGIN":taxt[2],"STAGE":taxt[3]})
				else:
					new_text.get_node("Title").text = ranel(INF_TITLE)
					taxt[seeds[1]] = ranel(INF_LTEXT[seeds[1]])
					new_text.get_node("LeftText").text = CAP_STR.format({"TYPE": taxt[0] , "REASON":taxt[1], "ORIGIN":taxt[2],"STAGE":taxt[3]})
			1: # errors in the right text/content
				if vaccine:
					var taxt = [ranel(INF_RTEXT[0]),ranel(INF_RTEXT[1]),ranel(INF_RTEXT[2]),ranel(INF_RTEXT[3])]
					new_text.get_node("RightText").text = CAP_STR.format({"TYPE": taxt[0] , "REASON":taxt[1], "ORIGIN":taxt[2],"STAGE":taxt[3]})
					
					return [new_text, taxt[0]]
				
				tixt[seeds[0]] = ranel(INF_RTEXT[seeds[0]])
				tixt[seeds[1]] = ranel(INF_RTEXT[seeds[1]])
				new_text.get_node("RightText").text = CAP_STR.format({"TYPE": tixt[0] , "REASON":tixt[1], "ORIGIN":tixt[2],"STAGE":tixt[3]})
			2: # errors in the glyco type + visible cell
				new_text.texture_normal = load("res://graphics/GlycocalyxSpecial.png")
	else:#if randi()%4 == 0: # rnadom chance if uninfected
		var seede = randi() % 4
		var seedes = randi() % 4
		match seede:
			0:
				new_text.texture_normal = load("res://graphics/GlycocalyxSpecial.png")
			1:
				tixt[seedes] = ranel(INF_RTEXT[seedes])
				new_text.get_node("RightText").text = JOB_STR.format({"Job": tixt[0] , "Reason":tixt[1], "Origin":tixt[2],"Stage":tixt[3]})
			2:
				var taxt = ["TYPE", "REASON", "LOCATION", "STAGE"]
				taxt[seedes] = ranel(INF_LTEXT[seedes])
				new_text.get_node("LeftText").text = CAP_STR.format({"TYPE": taxt[0] , "REASON":taxt[1], "ORIGIN":taxt[2],"STAGE":taxt[3]})
			3:
				new_text.get_node("Title").text = ranel(INF_TITLE)
	
	print("infected") if prson[0] == 2 else print("healthy")
	return [new_text, tixt[0]] # for the purposes of killing

func generate_hla():
	var new_text = HLA.instantiate()
	add_text(new_text)
	if cur_person[0] == 2: # infected
		new_text.get_node("LeftText").text = "[center]" + ranel(inf_hla)
	else:
		new_text.get_node("LeftText").text = "[center]" + ranel(norm_hla)
	
	return new_text

func generate_hla_codes():
	var new_text = cell_report.instantiate()
	add_text(new_text)
	
	new_text.get_node("TopText").text = "[center] Valid HLA Codes"
	new_text.get_node("BottomText").text = """
[center]{}
{}
{}
{}
{}
{}""".format(norm_hla, "{}")
	
	return new_text

func give_report():
	var new_text = cell_report.instantiate()
	add_text(new_text)
	new_text.get_node("TopText").text = "[center] PERFORMANCE REVIEW [/center]"
	new_text.get_node("BottomText").text = """In the last 6 cells you checked, you made {m} mistakes.

Your current score is now {s}.

If your score is below -10, your body will die to the bacteria and if it is above +15 your body will overcome the bacteria.""".format({"m": str(get_parent().last_mistakes), "s":str(get_parent().score)})
	
	new_text.position.x = - (load(new_text.texture_normal.load_path).get_width())/2
	return new_text # for the purposes of killing

# low-level functions
func add_text(text): # link up a text with the systems of movement and layering
	texts.append(text)
	
	max_layer += 1
	text.set_z_index(max_layer)
	text.position.x -= (load(text.texture_normal.load_path).get_width())/2
	text.position.y -= (load(text.texture_normal.load_path).get_height())/2
	
	text.connect("down", top)
	text.connect("up", untop)
	
	self.add_child(text) # potentially move this to the thing that generates text, or combine function of making text with this one

func top(text):
	if text in texts: # make sure it exists, could just use error
		# changing the drawing order
		for thing in texts:
			if thing.get_z_index() > text.get_z_index():
				thing.set_z_index(thing.get_z_index() - 1)
		text.set_z_index(max_layer)
		
		# changing the function management order
		var index = -1
		for child in get_children():
			index += 1
		move_child(text, index)
		
		# setting up node movement
		top_node = text
		o_mouse_pos = get_viewport().get_mouse_position() # probably not this simple

func untop(text):
	top_node = null
	o_mouse_pos = Vector2()

# killing is called only in TestDay.gd, based on a list in that script
func kill(text):
	for thing in texts:
		if thing.get_z_index() > text.get_z_index():
			thing.set_z_index(thing.get_z_index() - 1)
	
	texts.erase(text)
	text.queue_free()

func ranel(array):
	return array[randi() % array.size()]
