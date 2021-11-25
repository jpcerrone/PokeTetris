extends Node

var pokeball0 = preload("res://spr/poke0.png")
var pokeball1 = preload("res://spr/poke1.png")
var pokeball2 = preload("res://spr/poke2.png")
var pokeball3 = preload("res://spr/poke3.png")
var pokeball4 = preload("res://spr/poke4.png")
var pokeball5 = preload("res://spr/poke5.png")
var pokeball6 = preload("res://spr/poke6.png")
var pokeball7 = preload("res://spr/poke7.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getTextureForColorIndex(index):

	match (index):
		(0): return pokeball0
		(1): return pokeball1
		(2): return pokeball2
		(3): return pokeball3
		(4): return pokeball4
		(5): return pokeball5
		(6): return pokeball6
		(7): return pokeball7

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
