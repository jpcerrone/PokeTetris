extends Node2D

var positionInGrid:Vector2
var rotationState = 0
var shape

func getColorIndex():
	for i in range(shape.size()):
		for j in range(shape[0].size()):
			if shape[i][j] != 0:
				return shape[i][j]
	return 0
	
func getShapeWithoutBorders():
	var newShape = shape.duplicate(true)
	
	#Check and remove empty rows
	var rowsToRemove = []
	for i in range(shape.size()):
		var empty = true
		for j in range(shape[0].size()):
			if shape[j][i] != 0:
				empty = false
				break;
		if empty:
			rowsToRemove.append(i)
	MatrixOperations.removeRowsFromMatrix(newShape,rowsToRemove)
	
	#Check and remove empty columns
	var columnsToRemove = []
	for j in range(newShape.size()):
		var empty = true
		for i in range(newShape[0].size()):
			if newShape[j][i] != 0:
				empty = false
				break;
		if empty:
			columnsToRemove.append(j)
	
	MatrixOperations.removeColumnsFromMatrix(newShape, columnsToRemove)
	return newShape

func getTextureForPiece():
	return PokeballTextures.getTextureForColorIndex(getColorIndex())
