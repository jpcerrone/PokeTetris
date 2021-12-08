extends PiecePanel

var holdPiece: Piece

func swapPiece(piece: Piece):
	#Swap
	piece.shape = Constants.SHAPES[piece.getColorIndex()-1]
	var returnPiece = holdPiece
	holdPiece = piece
	Utilities.delete_children(self)
	drawPiece(piece, 0)
	return returnPiece
