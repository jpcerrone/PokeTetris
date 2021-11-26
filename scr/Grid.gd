extends Node2D

var grid = []
const gridWidth = 10
const gridHeight = 23
const vanishZone = 3

const spriteSize = 32
const dasDelay = 8

var darkMaterial = preload("res://extras/DarkMaterial.tres")
const Piece = preload("res://scr/Piece.gd")
var DropParticle = preload("res://scn/DropParticle.tscn")
var ClearParticle = preload("res://scn/ClearParticle.tscn")

var gridOffsetX
var gridOffsetY

var timer
var deltaSum
var clearedLines
var dasCounter
var lines = 0
var level = 1
var score = 0

var currentPiece: Piece
var speed

var hasSwapped

var currentBag
var nextBag

enum Direction {CLOCKWISE, ANTICLOCKWISE}
# Called when the node enters the scene tree for the first time.
func _ready():
	deltaSum = 0
	timer = 0
	speed = 1
	clearedLines = 0
	dasCounter = 0
	
	gridOffsetX = Global.screenSizeX/2 - gridWidth*spriteSize/2.0
	gridOffsetY = Global.screenSizeY/2 - gridHeight*spriteSize/2.0
	grid = MatrixOperations.create_2d_array(gridWidth, gridHeight, 0)
	
	currentBag = newBag()
	nextBag = newBag()
	
	spawnFromBag()
	$UI/NextPieces.drawPieces(currentBag, nextBag)
	drawGrid()
	drawDroppingPoint()
	hasSwapped = false

func newBag():
	var bagIndexes = [0,1,2,3,4,5,6]
	var newBagIndexes = bagIndexes.duplicate()
	newBagIndexes.shuffle()
	var bag = []
	while (!newBagIndexes.empty()):
		var piece = Piece.new()
		piece.shape = Piece.shapes[newBagIndexes.pop_back()]
		bag.append(piece)
	return bag

func drawGrid():
	#TODO: figure out better way to do this than delete children
	Utilities.delete_children(self)
	for x in range(gridWidth):
		for y in range(vanishZone-1,gridHeight):
			var circle = Sprite.new()
			if (y == 2):
				circle.region_enabled = true
				circle.region_rect = Rect2(0,6,16,10)
				circle.position = Vector2(x*spriteSize + gridOffsetX,y*spriteSize + gridOffsetY + 16)
			else:
				circle.position = Vector2(x*spriteSize + gridOffsetX,y*spriteSize + gridOffsetY)
			circle.texture = PokeballTextures.getTextureForColorIndex(grid[x][y])
			circle.scale = Vector2(2,2)
			circle.centered = false
			add_child(circle)

func addPiece():
	for x in currentPiece.shape.size():
		for y in currentPiece.shape[0].size():
			if currentPiece.shape[x][y] != 0:
				grid[currentPiece.positionInGrid.x+x][currentPiece.positionInGrid.y+y] = currentPiece.shape[x][y]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var sthHappened = false
	if Input.is_action_just_pressed("ui_right"):
		if canPieceMoveRight():
			movePieceInGrid(1,0)
			sthHappened = true
		deltaSum = 0
		dasCounter = 0
	if Input.is_action_just_pressed("ui_left"):
		if canPieceMoveLeft():
			movePieceInGrid(-1,0)
			sthHappened = true
		deltaSum = 0
		dasCounter = 0
	deltaSum += delta
	if (deltaSum > 2*delta) && (dasCounter>dasDelay):
		if Input.is_action_pressed("ui_right"):
			if canPieceMoveRight():
				movePieceInGrid(1,0)
				sthHappened = true
		if Input.is_action_pressed("ui_left"):
			if canPieceMoveLeft():
				movePieceInGrid(-1,0)
				sthHappened = true
		deltaSum = 0
	dasCounter+=1
	if Input.is_action_pressed("ui_down"):
			if canPieceMoveDown():
				movePieceInGrid(0,1)
				score += 1
				$UI/Score/ScoreNumber.text = str(score)
				sthHappened = true
	if Input.is_action_just_pressed("ui_up"):	
		hardDropPiece()
		afterDrop()
		sthHappened = true
		timer=0
	if Input.is_action_just_pressed("rotate_clockwise"):
		if canRotate(Direction.CLOCKWISE) == true:
			rotatePiece(Direction.CLOCKWISE)
			sthHappened = true
	if Input.is_action_just_pressed("rotate_anticlockwise"):
		if canRotate(Direction.ANTICLOCKWISE) == true:
			rotatePiece(Direction.ANTICLOCKWISE)
			sthHappened = true
	if Input.is_action_just_pressed("swap_piece"):
		if (!hasSwapped):
			deletePieceFromGrid()
			var heldPiece = $UI/Hold.swapPiece(currentPiece)
			if heldPiece:
				currentPiece = heldPiece
				spawnPiece()
			else:
				spawnFromBag()
			sthHappened = true
			hasSwapped = true
	timer += delta
	if timer >= speed:
		if canPieceMoveDown():
			movePieceInGrid(0,1)
		else:
			afterDrop()
		sthHappened = true
		timer=0
	if (sthHappened):
		drawGrid()
		drawDroppingPoint()
	
	
func afterDrop():
	currentPiece = Piece.new()
	checkAndClearFullLines()
	if (checkGameOver()):
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	spawnFromBag()
	hasSwapped = false

func drawDroppingPoint():
	deletePieceFromGrid()
	var droppingY = currentPiece.positionInGrid.y
	var foundDroppingLine = false

	while (!foundDroppingLine):
		for i in range(0,currentPiece.shape.size()):
			for j in range(currentPiece.shape[0].size()-1,-1,-1):
				if currentPiece.shape[i][j] != 0:
					if droppingY + j +1>=gridHeight:
						foundDroppingLine = true
						droppingY-=1
						break
					if (grid[currentPiece.positionInGrid.x + i][droppingY + j + 1] != 0):
						foundDroppingLine = true
						droppingY-=1
						break
		droppingY+=1
	addPiece()
	
	#draw shape with outline
	if droppingY >= vanishZone:
		for x in currentPiece.shape.size():
			for y in currentPiece.shape[0].size():
				if (currentPiece.shape[x][y] != 0) && (grid[currentPiece.positionInGrid.x + x][droppingY + y] == 0):
					var circle = Sprite.new()
					circle.position = Vector2(currentPiece.positionInGrid.x*spriteSize + x*spriteSize + gridOffsetX,droppingY*spriteSize+y*spriteSize + gridOffsetY)
					circle.texture = currentPiece.getTextureForPiece()
					circle.material = darkMaterial
					circle.scale = Vector2(2,2)
					circle.centered = false
					add_child(circle)
	
func hardDropPiece():
	while (canPieceMoveDown()):
		score += 2
		$UI/Score/ScoreNumber.text = str(score)
		movePieceInGrid(0,1)
	var particle = DropParticle.instance()
	particle.position.x = gridOffsetX + ((currentPiece.positionInGrid.x + currentPiece.shape.size()/float(2)))* spriteSize
	var pixelPosy = (currentPiece.positionInGrid.y+1)* spriteSize
	particle.position.y = (pixelPosy)/2 + gridOffsetY
	particle.setBoxRanges(Vector2(currentPiece.shape.size()/float(2)* spriteSize, pixelPosy/2 -spriteSize))
	particle.amount = pixelPosy/20
	match currentPiece.getColorIndex():
		1: particle.setColor(Color.red)
		2: particle.setColor(Color.blue)
		3: particle.setColor(Color.yellow)
		4: particle.setColor(Color.cyan)
		5: particle.setColor(Color.green)
		6: particle.setColor(Color.fuchsia)
		7: particle.setColor(Color.orange)
	add_child(particle)
	particle.emit()

func checkGameOver():
	for i in range (gridWidth):
		if grid[i][vanishZone-1] != 0:
			return true
	return	false

func checkAndClearFullLines():
	var cleared = 0
	for y in range(gridHeight):
		var fullLine = true
		for x in range(gridWidth):
			if grid[x][y] == 0:
				fullLine = false
				break;
		if fullLine:
			cleared+=1
			#Clear line
			for x in range(gridWidth):
				grid[x][y] = 0
			#Move everything down
			for j in range(y,0,-1):
				for i in range(gridWidth):
					if (grid[i][j] == 0) && (grid[i][j-1] != 0):
						grid[i][j] = grid[i][j-1]
						grid[i][j-1] = 0
			#Draw clear particle
			var particle = ClearParticle.instance()
			particle.position.x = gridOffsetX + spriteSize*gridWidth/2.0
			var pixelPosy = (y)* spriteSize
			particle.position.y = (pixelPosy) + gridOffsetY
			particle.setBoxRange(spriteSize*gridWidth/2.0)
			add_child(particle)
			particle.emit()
	#Scoring
	if cleared != 0:
		var newScore
		match (cleared):
			1: newScore=100*level
			2: newScore=300*level
			3: newScore=500*level
			4: newScore=800*level
		score += newScore
		lines += cleared
		$UI/Score/ScoreNumber.text = str(score)
		$UI/Lines/LinesNumber.text = str(lines)
		clearedLines += cleared
		if (clearedLines >= 10):
			clearedLines = 0
			level+=1
			speed = pow(0.8-(level-1)*0.007,level-1)
			$UI/Level/LevelNumber.text = str(level)

func movePieceInGrid(xMovement, yMovement):
	deletePieceFromGrid()
	#Write new position
	for x in range(0,currentPiece.shape.size()):
		for y in range(0,currentPiece.shape[0].size()):
			if currentPiece.shape[x][y] != 0:
				grid[x+xMovement+currentPiece.positionInGrid.x][y+yMovement+currentPiece.positionInGrid.y] = currentPiece.shape[x][y]
	currentPiece.positionInGrid.x = currentPiece.positionInGrid.x+xMovement
	currentPiece.positionInGrid.y = currentPiece.positionInGrid.y+yMovement
	
func spawnFromBag():
	if (!currentBag):
		currentBag = nextBag.duplicate()
		nextBag = newBag()
	currentPiece = currentBag.pop_front()
	spawnPiece()
	$UI/NextPieces.drawPieces(currentBag, nextBag)

func spawnPiece():
	var spawnIn = 1
	var startingX = (gridWidth - currentPiece.shape[0].size())/2
	for i in range(currentPiece.shape.size()):
		if currentPiece.shape[i][2] != 0 && grid[startingX + i][3] != 0:
			spawnIn = 0
			break;
	currentPiece.positionInGrid = Vector2((gridWidth - currentPiece.shape[0].size())/2, spawnIn)
	addPiece()

func canPieceMoveDown():
	for i in range(0,currentPiece.shape.size()):
		for j in range(currentPiece.shape[0].size()-1,-1,-1):
			if currentPiece.shape[i][j] != 0:
				if currentPiece.positionInGrid.y + j + 1 >= gridHeight:
					return false
				if grid[currentPiece.positionInGrid.x + i][currentPiece.positionInGrid.y + j + 1] != 0:
					return false
				else: break
	return true
	
func canPieceMoveRight():
	for j in currentPiece.shape[0].size():
		for i in range (currentPiece.shape.size()-1,-1,-1):
			if currentPiece.shape[i][j] != 0:
				if currentPiece.positionInGrid.x + i + 1 >= gridWidth:
					return false
				if grid[currentPiece.positionInGrid.x + i +1][currentPiece.positionInGrid.y + j] != 0:
					return false
				else: break
	return true

func canPieceMoveLeft():
	for j in currentPiece.shape[0].size():
		for i in currentPiece.shape.size():
			if currentPiece.shape[i][j] != 0:
				if currentPiece.positionInGrid.x + i <= 0:
					return false
				if grid[currentPiece.positionInGrid.x + i -1][currentPiece.positionInGrid.y + j] != 0:
					return false
				else: break
	return true

func rotatePiece(direction):
	deletePieceFromGrid()
	var newShape = MatrixOperations.invert2DMatrix(currentPiece.shape)
	if (direction == Direction.CLOCKWISE):
		newShape = MatrixOperations.swap2DMatrixColumns(newShape)
	else:
		newShape = MatrixOperations.swap2DMatrixRows(newShape)
	currentPiece.shape = newShape
	addPiece()

func canRotate(direction):
	var newShape = MatrixOperations.invert2DMatrix(currentPiece.shape)
	if (direction == Direction.CLOCKWISE):
		newShape = MatrixOperations.swap2DMatrixColumns(newShape)
	else:
		newShape = MatrixOperations.swap2DMatrixRows(newShape)
	deletePieceFromGrid()
	for i in newShape.size():
		for j in newShape[i].size():
			if (newShape[i][j]) != 0:
				#Check borders
				if (currentPiece.positionInGrid.x + i < 0) || (currentPiece.positionInGrid.x + i >= gridWidth):
					addPiece()
					return false
				if (currentPiece.positionInGrid.y + j + 1 > gridHeight):
					addPiece()
					return false
				if (grid[currentPiece.positionInGrid.x + i][currentPiece.positionInGrid.y + j] != 0):
					addPiece()
					return false
	addPiece()
	return true
	
func deletePieceFromGrid():
	#Delete old position
	for x in currentPiece.shape.size():
		for y in currentPiece.shape[0].size():
			if currentPiece.shape[x][y] != 0:
				grid[x+currentPiece.positionInGrid.x][y+currentPiece.positionInGrid.y] = 0
	
