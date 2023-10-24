from enum import Enum

class Rotation(Enum):
    CLOCKWISE = -90
    COUNTERCLOCKWISE = 90
    FLIP = 180

class Vector:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    def rotated(self, rotation: Rotation, axis: 'Vector') -> 'Vector':
        pass

X = Vector(1, 0, 0)
Y = Vector(0, 1, 0)
Z = Vector(0, 0, 1)

class Color(Enum):
    RED = 1
    GREEN = 2
    BLUE = 3
    YELLOW = 4
    ORANGE = 5
    WHITE = 6

class Face(Enum):
    FRONT = 1
    BACK = 2
    LEFT = 3
    RIGHT = 4
    TOP = 5
    BOTTOM = 6

class Piece:
    def __init__(self, position: Vector, colors: dict[Face, Color]):
        self.position = position
        self.colors = colors

class Cube:
    def __init__(self):
        self.pieces = []
        

