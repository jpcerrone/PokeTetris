extends Panel
class_name PiecePanel
 
const Piece = preload("res://scr/Piece.gd")

const spriteSize = 16

func drawPiece(piece: Piece, yOffset):
	var shapeWithoutBorders = piece.getShapeWithoutBorders()
	var panelMidPoint = rect_size.x/2.0
	var pieceSize = Vector2(shapeWithoutBorders.size() * spriteSize, shapeWithoutBorders[0].size() * spriteSize)
	var origin = Vector2(panelMidPoint - pieceSize.x/2.0,panelMidPoint - pieceSize.y/2.0 + yOffset)

	for i in range(shapeWithoutBorders.size()):
		for j in range(shapeWithoutBorders[0].size()):
			if (shapeWithoutBorders[i][j] != 0):
				var circle = Sprite.new()
				circle.position = Vector2(origin.x + spriteSize*i ,origin.y + spriteSize*j)
				circle.centered = false
				circle.texture = piece.getTextureForPiece()
				add_child(circle)
			
