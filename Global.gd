extends Node2D
var screenSizeX 
var screenSizeY
var score
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	screenSizeX = get_viewport().size.x
	screenSizeY = get_viewport().size.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
