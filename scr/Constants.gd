extends Node
#Shape described by column:
const I_SHAPE = [[0,1,0,0],[0,1,0,0],[0,1,0,0],[0,1,0,0]]
const J_SHAPE = [[2,2,0],[0,2,0],[0,2,0]]
const L_SHAPE = [[0,3,0],[0,3,0],[3,3,0]]
const O_SHAPE = [[0,0,0,0],[0,4,4,0],[0,4,4,0],[0,0,0,0]]
const T_SHAPE = [[0,5,0],[5,5,0],[0,5,0]]
const Z_SHAPE = [[6,0,0],[6,6,0],[0,6,0]]
const S_SHAPE = [[0,7,0],[7,7,0],[7,0,0]]

const SHAPES = [I_SHAPE, J_SHAPE, L_SHAPE, O_SHAPE, T_SHAPE, Z_SHAPE, S_SHAPE]
const KICK_TABLE = [[Vector2(0,0), Vector2(-1,0), Vector2(-1,-1), Vector2(0,2), Vector2(-1,2)], #0->1
						[Vector2(0,0), Vector2(1,0), Vector2(1,1), Vector2(0,-2), Vector2(1,-2)], #1->2
						[Vector2(0,0), Vector2(1,0), Vector2(1,-1), Vector2(0,2), Vector2(1,2)], #2->3
						[Vector2(0,0), Vector2(-1,0), Vector2(-1,1), Vector2(0,-2), Vector2(-1,-2)], #3->0
]
const KICK_TABLE_I = [[Vector2(0,0), Vector2(-2,0), Vector2(1,0), Vector2(-2,1), Vector2(1,-2)], #0->1
						[Vector2(0,0), Vector2(-1,0), Vector2(2,0), Vector2(-1,-2), Vector2(2,1)], #1->2
						[Vector2(0,0), Vector2(2,0), Vector2(-1,0), Vector2(2,-1), Vector2(-1,2)], #2->3
						[Vector2(0,0), Vector2(1,0), Vector2(-2,0), Vector2(1,2), Vector2(-2,-1)], #3->0
]
