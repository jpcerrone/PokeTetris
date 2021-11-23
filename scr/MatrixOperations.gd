extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_2d_array(width, height, value):
	var a = []
	for x in range(width):
		a.append([])
		a[x].resize(height)

		for y in range(height):
			a[x][y] = value
	return a

func invert2DMatrix(matrix):
	var newMatrix = MatrixOperations.create_2d_array(matrix[0].size(), matrix.size(), 0)
	for i in matrix.size():
		for j in matrix[i].size():
			newMatrix[j][i] = matrix[i][j]
	return newMatrix
	
func swap2DMatrixColumns(matrix):
	var newMatrix = MatrixOperations.create_2d_array(matrix.size(), matrix[0].size(), 0)
	for i in matrix.size():
		for j in matrix[i].size():
			newMatrix[i][j] = matrix[matrix.size() -1 - i][j]
	return newMatrix

func removeColumnsFromMatrix(matrix, columnIndexList):
	var retMatrix = []
	for i in range(matrix.size()):
		if !columnIndexList.has(i):
			retMatrix.append(matrix[i])
	matrix = retMatrix

func removeRowsFromMatrix(matrix, rowIndexList):
	for i in range(rowIndexList.size()-1,-1,-1):
		for j in range(matrix.size()):
			matrix[j].remove(rowIndexList[i])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
