extends Node

const pokeball0 = preload("res://spr/poke0.png")
const pokeball1 = preload("res://spr/poke1.png")
const pokeball2 = preload("res://spr/poke2.png")
const pokeball3 = preload("res://spr/poke3.png")
const pokeball4 = preload("res://spr/poke4.png")
const pokeball5 = preload("res://spr/poke5.png")
const pokeball6 = preload("res://spr/poke6.png")
const pokeball7 = preload("res://spr/poke7.png")

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
