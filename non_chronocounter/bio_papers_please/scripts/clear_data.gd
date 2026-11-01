extends Node2D

const SAVE_PATH = "user://save.sv"

# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		dir.remove("save.sv")
	
	var save_game = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_game.store_line("0")
	save_game.store_line("-1")
	save_game.store_line("1")
	save_game.store_line("0")
	save_game.store_line("-1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
