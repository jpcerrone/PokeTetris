extends PiecePanel

const numberOfPieces = 5
const separation = 64

func drawPieces(currentBag, nextBag):
	Utilities.delete_children(self)
	var fullQueue = currentBag.duplicate()
	fullQueue.append_array(nextBag)
	for i in range(numberOfPieces):
		drawPiece(fullQueue[i], i*separation)
