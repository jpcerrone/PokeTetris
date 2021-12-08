extends Node2D
var screenSizeX 
var screenSizeY

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSizeX = get_viewport().size.x
	screenSizeY = get_viewport().size.y
