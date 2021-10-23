extends Node2D
var grid = []
const gridWidth = 10
const gridHeight = 22
const vanishZone = 2
const spriteSize = 32
const level = 1
var pokeball0 = preload("res://spr/poke0.png")
var pokeball1 = preload("res://spr/poke1.png")
var pokeball2 = preload("res://spr/poke2.png")
var pokeball3 = preload("res://spr/poke3.png")
var pokeball4 = preload("res://spr/poke4.png")
var pokeball5 = preload("res://spr/poke5.png")
var pokeball6 = preload("res://spr/poke6.png")
const Piece = preload("res://Piece.gd")
signal score_change
var timer
var deltaSum
#Use this as global instead of passing piece to every function
var currentPiece

func delete_children():
	for n in get_children():
		remove_child(n)
		n.queue_free()

func drawGrid():
	#TODO: figure out better way to do this than delete children
	delete_children()
	for x in range(gridWidth):
		for y in range(vanishZone,gridHeight):
			var circle = Sprite.new()
			var gridOffsetX = Global.screenSizeX/2 - gridWidth*spriteSize/2
			var gridOffsetY = Global.screenSizeY/2 - gridHeight*spriteSize/2
			circle.position = Vector2(x*spriteSize + gridOffsetX,y*spriteSize + gridOffsetY)
			match (grid[x][y]):
				(0): circle.texture = pokeball0
				(1): circle.texture = pokeball1
				(2): circle.texture = pokeball2
				(3): circle.texture = pokeball3
				(4): circle.texture = pokeball4
				(5): circle.texture = pokeball5
				(6): circle.texture = pokeball6
			circle.scale = Vector2(2,2)
			circle.centered = false
			add_child(circle)
			pass

# Called when the node enters the scene tree for the first time.
func _ready():
	deltaSum = 0
	timer = 0
	currentPiece = get_parent().get_node("Piece")
	grid = MatrixOperations.create_2d_array(gridWidth, gridHeight, 0)
	spawnPiece(currentPiece)
	drawGrid()
	pass # Replace with function body.

func addPiece(piece: Piece):
	for x in piece.shape.size():
		for y in piece.shape[0].size():
			if piece.shape[x][y] != 0:
				grid[piece.positionInGrid.x+x][piece.positionInGrid.y+y] = piece.shape[x][y]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right"):
		if canPieceMoveRight(currentPiece):
				movePieceInGrid(currentPiece,1,0)
		deltaSum = 0
	if Input.is_action_just_pressed("ui_left"):
		if canPieceMoveLeft(currentPiece):
				movePieceInGrid(currentPiece,-1,0)
		deltaSum = 0
	deltaSum += delta
	if (deltaSum > 4*delta):
		if Input.is_action_pressed("ui_right"):
				if canPieceMoveRight(currentPiece):
					movePieceInGrid(currentPiece,1,0)
		if Input.is_action_pressed("ui_left"):
			if canPieceMoveLeft(currentPiece):
				movePieceInGrid(currentPiece,-1,0)
		deltaSum = 0
	if Input.is_action_pressed("ui_down"):
			#if canPieceMoveLeft(currentPiece):
			if canPieceMoveDown(currentPiece):
				movePieceInGrid(currentPiece,0,1)
	if Input.is_action_just_pressed("ui_up"):	
		hardDropPiece()
	if Input.is_action_just_pressed("rotate_piece_left"):
		if canRotate(currentPiece) == true:
			rotatePiece(currentPiece)
	timer += delta
	if timer >= 0.2:
		if canPieceMoveDown(currentPiece):
			movePieceInGrid(currentPiece,0,1)
		else:
			currentPiece = Piece.new()
			checkAndClearFullLines()
			if (checkGameOver()):
				get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
			spawnPiece(currentPiece)
		timer=0
	drawGrid()
	
	
func hardDropPiece():
	while (canPieceMoveDown(currentPiece)):
		Global.score += 2
		emit_signal("score_change", Global.score)
		movePieceInGrid(currentPiece,0,1)
func checkGameOver():
	for i in range (gridWidth):
		if grid[i][0] != 0:
			return true
	return	false



func checkAndClearFullLines():
	var cleared = 0
	for y in range(gridHeight):
		var fullLine = true
		for x in range(gridWidth-1):
			if grid[x][y] == 0:
				fullLine = false
				break;
		if fullLine && grid[gridWidth-1][y] != 0:
			cleared+=1
			#Clear line
			for x in range(gridWidth):
				grid[x][y] = 0
	#Move everything down
	for i in range(cleared):
		for y in range(gridHeight-1,0,-1):
			for x in range(gridWidth):
				if (grid[x][y] == 0) && (grid[x][y-1] != 0):
					grid[x][y] = grid[x][y-1]
					grid[x][y-1] = 0
	#Scoring
	var score
	if cleared != 0:
		match (cleared):
			1: score=100*level
			2: score=300*level
			3: score=500*level
			4: score=800*level
		Global.score += score
		emit_signal("score_change", Global.score)
func _on_PieceMoveTimer_timeout():
	#TODO: Replace this function with better logic for whole object
	pass
	#drawGrid()


func movePieceInGrid(piece: Piece, xMovement, yMovement):
	deletePieceFromGrid(piece)
	#Write new position
	for x in range(0,piece.shape.size()):
		for y in range(0,piece.shape[0].size()):
			if piece.shape[x][y] != 0:
				grid[x+xMovement+piece.positionInGrid.x][y+yMovement+piece.positionInGrid.y] = piece.shape[x][y]
	piece.positionInGrid.x = piece.positionInGrid.x+xMovement
	piece.positionInGrid.y = piece.positionInGrid.y+yMovement
	
	
func spawnPiece(piece:Piece):
	piece.positionInGrid = Vector2((gridWidth - piece.shape[0].size())/2,0)
	addPiece(currentPiece)
	pass

func canPieceMoveDown(piece: Piece):
	var rows = piece.shape[0].size()
	if piece.positionInGrid.y == gridHeight - rows:
		return false
	for i in range(0,piece.shape.size()):
		for j in range(piece.shape[0].size()-1,-1,-1):
			if piece.shape[i][j] != 0:
				if grid[piece.positionInGrid.x + i][piece.positionInGrid.y + j + 1] != 0:
					return false
				else: break
	return true
	
func canPieceMoveRight(piece: Piece):
	if piece.positionInGrid.x == (gridWidth - piece.shape.size()):
		return false
	for j in piece.shape[0].size():
		for i in range (piece.shape.size()-1,-1,-1):
			if piece.shape[i][j] != 0:
				if grid[piece.positionInGrid.x + i +1][piece.positionInGrid.y + j] != 0:
					return false
				else: break
	return true

func canPieceMoveLeft(piece: Piece):
	if piece.positionInGrid.x == 0:
		return false
	for j in piece.shape[0].size():
		for i in piece.shape.size():
			if piece.shape[i][j] != 0:
				if grid[piece.positionInGrid.x + i -1][piece.positionInGrid.y + j] != 0:
					return false
				else: break
	return true

func rotatePiece(piece: Piece):
	#TODO: rotate around center
	deletePieceFromGrid(piece)
	var newShape = MatrixOperations.swap2DMatrixColumns(MatrixOperations.invert2DMatrix(piece.shape))
	piece.shape = newShape
	addPiece(piece)

func canRotate(piece: Piece):
	var newShape = MatrixOperations.swap2DMatrixColumns(MatrixOperations.invert2DMatrix(piece.shape))
	#Check borders
	if (piece.positionInGrid.y + newShape[0].size() > gridHeight):
		return false
	if (piece.positionInGrid.x + newShape.size() > gridWidth):
		return false
	#Check other blocks
	deletePieceFromGrid(piece)
	for i in newShape.size():
		for j in newShape[i].size():
			if (newShape[i][j]) != 0 && (grid[piece.positionInGrid.x + i][piece.positionInGrid.y + j] != 0):
				addPiece(piece)
				return false
	addPiece(piece)
	return true
	
func deletePieceFromGrid(piece: Piece):
	#Delete old position
	for x in piece.shape.size():
		for y in piece.shape[0].size():
			if piece.shape[x][y] != 0:
				grid[x+piece.positionInGrid.x][y+piece.positionInGrid.y] = 0
	