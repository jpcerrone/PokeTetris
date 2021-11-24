extends Node2D
var grid = []
const gridWidth = 10
const gridHeight = 23
const vanishZone = 3
const spriteSize = 32
const dasDelay = 8
var pokeball0 = preload("res://spr/poke0.png")
var pokeball1 = preload("res://spr/poke1.png")
var pokeball2 = preload("res://spr/poke2.png")
var pokeball3 = preload("res://spr/poke3.png")
var pokeball4 = preload("res://spr/poke4.png")
var pokeball5 = preload("res://spr/poke5.png")
var pokeball6 = preload("res://spr/poke6.png")
var pokeball7 = preload("res://spr/poke7.png")

var pokeballBorder = preload("res://spr/pokeDrop.png")
var darkMaterial = preload("res://extras/DarkMaterial.tres")
const Piece = preload("res://scr/Piece.gd")
var DropParticle = preload("res://scn/DropParticle.tscn")
var ClearParticle = preload("res://scn/ClearParticle.tscn")
var gridOffsetX
var gridOffsetY
signal score_change
signal level_change
signal lines_change

var timer
var deltaSum
var clearedLines
var dasCounter
var lines = 0
var level = 1
var score = 0
#Use this as global instead of passing piece to every function
var currentPiece
var speed

var hasSwapped

var currentBag
var nextBag

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
	drawGrid()
	drawDroppingPoint(currentPiece)
	hasSwapped = false

func newBag():
	var bagIndexes = [0,1,2,3,4,5,6]
	var bag = bagIndexes.duplicate()
	bag.shuffle()
	return bag

func delete_children():
	for n in get_children():
		if n.is_class("Sprite"):
			remove_child(n)
			n.queue_free()

func drawGrid():
	#TODO: figure out better way to do this than delete children
	delete_children()
	for x in range(gridWidth):
		for y in range(vanishZone-1,gridHeight):
			var circle = Sprite.new()
			circle.z_index = -1
			if (y == 2):
				circle.region_enabled = true
				circle.region_rect = Rect2(0,6,16,10)
				circle.position = Vector2(x*spriteSize + gridOffsetX,y*spriteSize + gridOffsetY + 16)
			else:
				circle.position = Vector2(x*spriteSize + gridOffsetX,y*spriteSize + gridOffsetY)
			circle.texture = getTextureForValue(grid[x][y])
			circle.scale = Vector2(2,2)
			circle.centered = false
			add_child(circle)
			pass

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
	

func addPiece(piece: Piece):
	for x in piece.shape.size():
		for y in piece.shape[0].size():
			if piece.shape[x][y] != 0:
				grid[piece.positionInGrid.x+x][piece.positionInGrid.y+y] = piece.shape[x][y]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var sthHappened = false
	if Input.is_action_just_pressed("ui_right"):
		if canPieceMoveRight(currentPiece):
			movePieceInGrid(currentPiece,1,0)
			sthHappened = true
		deltaSum = 0
		dasCounter = 0
	if Input.is_action_just_pressed("ui_left"):
		if canPieceMoveLeft(currentPiece):
			movePieceInGrid(currentPiece,-1,0)
			sthHappened = true
		deltaSum = 0
		dasCounter = 0
	deltaSum += delta
	if (deltaSum > 2*delta) && (dasCounter>dasDelay):
		if Input.is_action_pressed("ui_right"):
			if canPieceMoveRight(currentPiece):
				movePieceInGrid(currentPiece,1,0)
				sthHappened = true
		if Input.is_action_pressed("ui_left"):
			if canPieceMoveLeft(currentPiece):
				movePieceInGrid(currentPiece,-1,0)
				sthHappened = true
		deltaSum = 0
	dasCounter+=1
	if Input.is_action_pressed("ui_down"):
			if canPieceMoveDown(currentPiece):
				movePieceInGrid(currentPiece,0,1)
				score += 1
				emit_signal("score_change", score)
				sthHappened = true
	if Input.is_action_just_pressed("ui_up"):	
		hardDropPiece()
		afterDrop()
		sthHappened = true
		timer=0
	if Input.is_action_just_pressed("rotate_piece_left"):
		if canRotate(currentPiece) == true:
			rotatePiece(currentPiece)
			sthHappened = true
	if Input.is_action_just_pressed("swap_piece"):
		if (!hasSwapped):
			deletePieceFromGrid(currentPiece)
			var heldPiece = $Hold.swapPiece(currentPiece)
			if heldPiece:
				currentPiece = heldPiece
				spawnPiece(currentPiece)
			else:
				spawnFromBag()
			sthHappened = true
			hasSwapped = true
	timer += delta
	if timer >= speed:
		if canPieceMoveDown(currentPiece):
			movePieceInGrid(currentPiece,0,1)
		else:
			afterDrop()
		sthHappened = true
		timer=0
	if (sthHappened):
		drawGrid()
		drawDroppingPoint(currentPiece)
	
	
func afterDrop():
	currentPiece = Piece.new()
	checkAndClearFullLines()
	if (checkGameOver()):
		get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	spawnFromBag()
	hasSwapped = false

func drawDroppingPoint(piece: Piece):
	deletePieceFromGrid(piece)
	var droppingY = piece.positionInGrid.y
	var foundDroppingLine = false
	#while (!foundDroppingLine) && (droppingY<gridHeight-piece.shape[0].size()):
	while (!foundDroppingLine):
		for i in range(0,piece.shape.size()):
			for j in range(piece.shape[0].size()-1,-1,-1):
				if piece.shape[i][j] != 0:
					if droppingY + j +1>=gridHeight:
						foundDroppingLine = true
						droppingY-=1
						break
					if (grid[piece.positionInGrid.x + i][droppingY + j + 1] != 0):
						foundDroppingLine = true
						droppingY-=1
						break
		droppingY+=1
	addPiece(piece)
	#draw shape with outline
	if droppingY >= vanishZone:
		for x in piece.shape.size():
			for y in piece.shape[0].size():
				if (piece.shape[x][y] != 0) && (grid[piece.positionInGrid.x + x][droppingY + y] == 0):
					var circle = Sprite.new()
					circle.z_index = -1
					circle.position = Vector2(piece.positionInGrid.x*spriteSize + x*spriteSize + gridOffsetX,droppingY*spriteSize+y*spriteSize + gridOffsetY)
					circle.texture = getTextureForValue(piece.getColorIndex())
					circle.material = darkMaterial
					circle.scale = Vector2(2,2)
					circle.centered = false
					add_child(circle)
	
func hardDropPiece():
	while (canPieceMoveDown(currentPiece)):
		score += 2
		emit_signal("score_change", score)
		movePieceInGrid(currentPiece,0,1)
	var particle = DropParticle.instance()
	#particle.position.x = ((currentPiece.positionInGrid.x* spriteSize +currentPiece.shape.size()*spriteSize)/2) + gridOffsetX
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
		emit_signal("score_change", score)
		emit_signal("lines_change", lines)
		clearedLines += cleared
		if (clearedLines >= 10):
			clearedLines = 0
			level+=1
			speed = pow(0.8-(level-1)*0.007,level-1)
			emit_signal("level_change", level)

func movePieceInGrid(piece: Piece, xMovement, yMovement):
	deletePieceFromGrid(piece)
	#Write new position
	for x in range(0,piece.shape.size()):
		for y in range(0,piece.shape[0].size()):
			if piece.shape[x][y] != 0:
				grid[x+xMovement+piece.positionInGrid.x][y+yMovement+piece.positionInGrid.y] = piece.shape[x][y]
	piece.positionInGrid.x = piece.positionInGrid.x+xMovement
	piece.positionInGrid.y = piece.positionInGrid.y+yMovement
	
func spawnFromBag():
	currentPiece = Piece.new()
	if (!currentBag):
		currentBag = nextBag.duplicate()
		nextBag = newBag()
	currentPiece.shape = Piece.shapes[currentBag.pop_front()]
	spawnPiece(currentPiece)

func spawnPiece(piece: Piece):
	var spawnIn = 1
	var startingX = (gridWidth - piece.shape[0].size())/2
	for i in range(piece.shape.size()):
		if piece.shape[i][2] != 0 && grid[startingX + i][3] != 0:
			spawnIn = 0
			break;
	piece.positionInGrid = Vector2((gridWidth - piece.shape[0].size())/2, spawnIn)
	addPiece(piece)

func canPieceMoveDown(piece: Piece):
	for i in range(0,piece.shape.size()):
		for j in range(piece.shape[0].size()-1,-1,-1):
			if piece.shape[i][j] != 0:
				if piece.positionInGrid.y + j + 1 >= gridHeight:
					return false
				if grid[piece.positionInGrid.x + i][piece.positionInGrid.y + j + 1] != 0:
					return false
				else: break
	return true
	
func canPieceMoveRight(piece: Piece):
	#if piece.positionInGrid.x == (gridWidth - piece.shape.size()):
		#return false
	for j in piece.shape[0].size():
		for i in range (piece.shape.size()-1,-1,-1):
			if piece.shape[i][j] != 0:
				if piece.positionInGrid.x + i + 1 >= gridWidth:
					return false
				if grid[piece.positionInGrid.x + i +1][piece.positionInGrid.y + j] != 0:
					return false
				else: break
	return true

func canPieceMoveLeft(piece: Piece):
	for j in piece.shape[0].size():
		for i in piece.shape.size():
			if piece.shape[i][j] != 0:
				if piece.positionInGrid.x + i <= 0:
					return false
				if grid[piece.positionInGrid.x + i -1][piece.positionInGrid.y + j] != 0:
					return false
				else: break
	return true

func rotatePiece(piece: Piece):
	deletePieceFromGrid(piece)
	var newShape = MatrixOperations.swap2DMatrixColumns(MatrixOperations.invert2DMatrix(piece.shape))
	piece.shape = newShape
	addPiece(piece)

func canRotate(piece: Piece):
	var newShape = MatrixOperations.swap2DMatrixColumns(MatrixOperations.invert2DMatrix(piece.shape))
	#Check borders
	#Check other blocks
	deletePieceFromGrid(piece)
	for i in newShape.size():
		for j in newShape[i].size():
			if (newShape[i][j]) != 0:
				#Check borders
				if (piece.positionInGrid.x + i < 0) || (piece.positionInGrid.x + i >= gridWidth):
					addPiece(piece)
					return false
				if (piece.positionInGrid.y + j + 1 > gridHeight):
					addPiece(piece)
					return false
				if (grid[piece.positionInGrid.x + i][piece.positionInGrid.y + j] != 0):
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
	
