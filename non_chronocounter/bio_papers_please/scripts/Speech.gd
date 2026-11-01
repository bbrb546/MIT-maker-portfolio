extends Node2D

var text = "PLACEHOLDER"

# flip related
var is_flipped = false

# noite to self - for some reason setting variables equal to the child nodes of the packed scene doesn't work

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_text(string, why):
	$Label.text = string
	self.position.y = why
	text = string
	
	# update appearance
	$SpeechCenter.scale.x = len($Label.text.split()) * 1.5
	var sscale = $SpeechCenter.scale.x
	
	$SpeechCenter.position.x = -((sscale - 1) * 5) - 15
	$SpeechLeft.position.x = $SpeechCenter.position.x - (((sscale - 1) * 5) + 10)
	$Label.position.x = $SpeechLeft.position.x + 3
	
	print("label: " + str($Label.position))
	print("speechleft: " + str($SpeechLeft.position))

func flip(): # is_flipped begins false it it isn't flipped, true if it is
	pass
