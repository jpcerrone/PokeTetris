extends Panel
const Piece = preload("res://scr/Piece.gd")
var holdPiece: Piece
var spriteSize = 16

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
	Utilities.delete_children(self)

	for i in range(shapeWithoutBorders.size()):
		for j in range(shapeWithoutBorders[0].size()):
			if (shapeWithoutBorders[i][j] != 0):
				var circle = Sprite.new()
				circle.position = Vector2(origin.x + spriteSize*i ,origin.y + spriteSize*j)
				circle.centered = false
				circle.texture = holdPiece.getTextureForPiece()
				add_child(circle)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
