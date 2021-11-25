extends Panel

const Piece = preload("res://scr/Piece.gd")

const numberOfPieces = 5
const separation = 64

var spriteSize = 16

# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.

func drawPieces(currentBag, nextBag):
	delete_children()
	var fullQueue = currentBag.duplicate()
	fullQueue.append_array(nextBag)
	for i in range(numberOfPieces):
		drawPiece(fullQueue[i], i*separation)
func drawPiece(piece: Piece, offset):
	#TODO: REPEATED CODE FROM HOLD!!!
	var shapeWithoutBorders = piece.getShapeWithoutBorders()
	var panelMidPoint = rect_size.x/2.0
	var pieceSize = Vector2(shapeWithoutBorders.size() * spriteSize, shapeWithoutBorders[0].size() * spriteSize)
	var origin = Vector2(panelMidPoint - pieceSize.x/2.0,panelMidPoint - pieceSize.y/2.0 + offset)

	for i in range(shapeWithoutBorders.size()):
		for j in range(shapeWithoutBorders[0].size()):
			if (shapeWithoutBorders[i][j] != 0):
				var circle = Sprite.new()
				circle.position = Vector2(origin.x + spriteSize*i ,origin.y + spriteSize*j)
				circle.centered = false
				circle.texture = piece.getTextureForPiece()
				add_child(circle)

func delete_children():
	#REFACTOR ABSTARACT
	for n in get_children():
		if n.is_class("Sprite"):
			remove_child(n)
			n.queue_free()
			
