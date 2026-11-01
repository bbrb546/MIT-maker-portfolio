extends Node2D

@onready var data = FileAccess.open("res://data.txt", FileAccess.READ)
@onready var content = """2`Welcome!``yes`````````
2`You are a white blood cell in the bloodstream``yes`````````
2`Your body has been infected with a bacteria``yes`````````
2`This bacteria disguises itself as normal cells in the body``yes`````````
2`Normal cells may contain up to 1 mistake in their ID, but the bacteria will always contain 2+ mistakes``yes`````````
2`You must identify and destroy them without too much collateral damage``yes````````[VACS]
2`You may opt to first receive a vaccine or play without it``yes````````
2`Good luck``yes````````[END]
2`That was the vaccine mode!``yes````````
2`You just received 6 instances of weakened bacteria``yes````````
2`This is similar to how some types of vaccines work in real life``yes````````
2`These vaccines inject you with a weakened form of a pathogen``yes````````
2`This allows your body to adapt to the pathogen``yes````````
2`There are many other types of vaccines that work in different ways. ``yes````````
2`For example, there are mRNA vaccines that use mRNA which serves as instructions for your cells to produce parts of a pathogen``yes````````
2`Another type are subunit-esque vaccines that only inject you with certain parts of the pathogen.``yes````````
2`But all types of vaccines help your immune system build a memory that is used to combat more dangerous versions of the pathogen in the future``yes````````
2`In this game, you represent your immune system adapting to the bacteria through a vaccine``yes````````
2`The bacteria from here on out will be better disguised, but their disguise will still follow the patterns you noticed in vaccine mode``yes````````
2`Good luck!``yes````````[END]
2`Unfortunately, you failed...``yes````````
2`You destroyed too many healthy cells and let too many bacteria through```yes````````
2`Select the vaccine mode to have a leg up in combatting the infection``yes````````
2`A common myth is that vaccines are more dangerous than the diseases they defend against``yes````````
2`However, try the vaccine mode to learn what vaccines actually do and experience how they work``yes```21`````
2`Congratulations! You successfully overcame the bacteria!``yes````````
2`You have simulated how your own immune system might adapt to a bacteria.``yes````````
2`There is a common myth that vaccines are more dangerous than the diseases they prevent``yes````````
2`This may seem true since vaccine needles can be scary, you often feel worse after taking one, and negative media/politician statements.``yes````````
2`However, this myth that vaccines are more dangerous is false.``yes````````
2`It is very dangerous and benefits politicans who can use fear of vaccines to gain political power or organizations who sell alternative health solutions``yes````````
2`Less vaccination can lead to many unneeded deaths and the resurgence of dead diseases, such as measles.``yes````````
2`However, if you picked vaccine mode, you would have learned about how vaccines help you overcome pathogens and the diseases they cause``yes````````
2`In summary, vaccines work by helping your immune system adapt to weaker versions of a pathogen``yes````````
2`For example, some vaccines inject your body with dead pathogens that your immune system adapts to``yes````````
2`Your immune system adapts by constantly mutating to produce effective proteins (antibodies) that can recognize foreign pathogens``yes````````
2`Mutations in the DNA influence the shape of the proteins produced, which in turn influence the effectiveness of the protein at attaching to and neutralizing a specific pathogen``yes````````
2`The term vaccine was first coined in in the late 18th century, around the time when the first vaccine - a smallpox vaccine - was developed``yes````````
2`Vaccines have been used to combat a wide variety of diseases since then, including influenza, polio, measles, and COVID-19.``yes````````
2`Thanks to vaccines, around 154 million people have been saved globally from 1974 to 2024.``yes````````
2`So the next time your doctor tells you to get a shot, remember that vaccines aren't dangerous - they are just a training tool to help fight off germs``yes````````
2`Thanks for playing!``yes````````
2`Sources: https://www.hhs.gov/immunization/basics/types/index.html, https://www.ncbi.nlm.nih.gov/books/NBK279396/ ``yes````````
2`More sources: https://www.ncbi.nlm.nih.gov/books/NBK546670/, https://www.who.int/news/item/24-04-2024-global-immunization-efforts-have-saved-at-least-154-million-lives-over-the-past-50-years``yes````````[ENDS]
2`More more sources: https://www.sciencedirect.com/topics/biochemistry-genetics-and-molecular-biology/glycocalyx, https://bioivt.com/blogs/what-is-hla-typing-cells-genotyped. The game is over now.``yes```40`````
""".split("\n")#Array(data.get_as_text().split("\n")) # array element for each line

var active_scene = 0

func _ready():
	var new_content = content
	content = []
	for i in range(0, len(new_content)):
		content.append(new_content[i].split("`")) # scene id = placement in the array
	
	$YapNext.connect("button_up", o1down)
	
	active_scene = 0
	load_scene(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func o1down():
	$YapVac.hide()
	$YapNoVac.hide()
	$YapNext.show()
	load_scene(active_scene + 1 if str(content[active_scene][6]) == "" else int(content[active_scene][6]))
func vacdown():
	$YapVac.hide()
	$YapNoVac.hide()
	$YapNext.show()
	get_parent().vaccine_setup()
	load_scene(active_scene + 1)


func load_scene(id):
	if content[active_scene][11]: # special events
		if content[active_scene][11].contains("[END]"):
			hide()
			get_parent().begin()
			return -1
		if content[active_scene][11].contains("[VACS]"):
			$YapNext.hide()
			$YapVac.show()
			$YapNoVac.show()
			$YapVac.connect("button_up", vacdown)
			$YapNoVac.connect("button_up", o1down)
		if content[active_scene][11].contains("[ENDS]"):
			$YapNext.hide()
	
	active_scene = id
	
	# setting up the images
	#$YapArt.texture = load('res://graphics/' + str(content[id][0])+'.png')
	$YapPanelContainer/RichTextLabel.text = center(content[id][1])

func center(text):
	return "[center]" + text + "[/center]"
