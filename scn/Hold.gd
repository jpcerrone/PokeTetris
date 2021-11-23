extends Panel
const Piece = preload("res://scr/Piece.gd")
var holdPiece: Piece
var spriteSize = 16
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
	#holdPiece = Piece.new()
	#holdPiece.shape = Piece.shapes[4]
	#drawPiece()
	pass # Replace with function body.

func swapPiece(piece: Piece):
	piece.shape = Piece.shapes[piece.getColorIndex()-1]
	var returnPiece = holdPiece
	holdPiece = piece
	drawPiece()
	return returnPiece

func drawPiece():
	var shapeWithoutBorders = holdPiece.getShapeWithoutBorders()
	var panelMidPoint = rect_size.x/2.0
	var pieceSize = Vector2(shapeWithoutBorders.size() * spriteSize, shapeWithoutBorders[0].size() * spriteSize)
	var origin = Vector2(panelMidPoint - pieceSize.x/2.0,panelMidPoint - pieceSize.y/2.0)
	delete_children()

	for i in range(shapeWithoutBorders.size()):
		for j in range(shapeWithoutBorders[0].size()):
			if (shapeWithoutBorders[i][j] != 0):
				var circle = Sprite.new()
				circle.position = Vector2(origin.x + spriteSize*i ,origin.y + spriteSize*j)
				circle.centered = false
				circle.texture = getTextureForValue(holdPiece.getColorIndex())
				add_child(circle)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func delete_children():
	#REFACTOR ABSTARACT
	for n in get_children():
		if n.is_class("Sprite"):
			remove_child(n)
			n.queue_free()

func getTextureForValue(value):
	match (value):
		(0): return pokeball0
		(1): return pokeball1
		(2): return pokeball2
		(3): return pokeball3
		(4): return pokeball4
		(5): return pokeball5
		(6): return pokeball6
		(7): return pokeball7
