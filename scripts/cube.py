from enum import Enum
import unittest


class Rotation(Enum):
    CLOCKWISE = -90
    COUNTER_CLOCKWISE = 90
    FLIP = 180

    @property
    def reversed(self) -> 'Rotation':
        if self == Rotation.CLOCKWISE:
            return Rotation.COUNTER_CLOCKWISE
        elif self == Rotation.COUNTER_CLOCKWISE:
            return Rotation.CLOCKWISE
        else:
            return self

    def rotate(self, a, b):
        if self == Rotation.CLOCKWISE:
            return b, -a
        elif self == Rotation.COUNTER_CLOCKWISE:
            return -b, a
        else:
            return -a, -b


# ------------------------------------------------------------------------------------

class Vector:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.z = z

    def __str__(self) -> str:
        return f'({self.x}, {self.y}, {self.z})'

    def __repr__(self) -> str:
        return f'Vector({self.x}, {self.y}, {self.z})'

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Vector):
            return False
        return self.x == other.x and self.y == other.y and self.z == other.z

    def __ne__(self, other: object) -> bool:
        return not self.__eq__(other)

    def __neg__(self) -> 'Vector':
        return Vector(-self.x, -self.y, -self.z)

    def rotated(self, axis: 'Vector', rotation: Rotation) -> 'Vector':
        x, y, z = self.x, self.y, self.z

        if axis == X:
            y, z = rotation.rotate(y, z)
        elif axis == -X:
            y, z = rotation.reversed.rotate(y, z)
        elif axis == Y:
            z, x = rotation.rotate(z, x)
        elif axis == -Y:
            z, x = rotation.reversed.rotate(z, x)
        elif axis == Z:
            x, y = rotation.rotate(x, y)
        elif axis == -Z:
            x, y = rotation.reversed.rotate(x, y)

        return Vector(x, y, z)

    @property
    def rounded(self) -> 'Vector':
        return Vector(round(self.x), round(self.y), round(self.z))


X = Vector(1, 0, 0)
Y = Vector(0, 1, 0)
Z = Vector(0, 0, 1)


class TestVector(unittest.TestCase):
    def test_vector(self):
        self.assertEqual(X, Vector(1, 0, 0))

    def test_negative(self):
        self.assertEqual(-X, Vector(-1, 0, 0))

    def test_rounded(self):
        self.assertEqual(Vector(0, 1.1, 0).rounded, Y)

    def test_rotated(self):
        self.assertEqual(X.rotated(Z, Rotation.CLOCKWISE), -Y)
        self.assertEqual(X.rotated(Y, Rotation.COUNTER_CLOCKWISE), -Z)

        self.assertEqual(Y.rotated(X, Rotation.FLIP), -Y)
        self.assertEqual(Y.rotated(Z, Rotation.FLIP), -Y)
        self.assertEqual(Y.rotated(Y, Rotation.FLIP), Y)

        self.assertEqual(Z.rotated(X, Rotation.CLOCKWISE), Y)


# ------------------------------------------------------------------------------------

class Color(Enum):
    RED = "Red"
    ORANGE = "Orange"
    WHITE = "White"
    YELLOW = "Yellow"
    GREEN = "Green"
    BLUE = "Blue"

    def __repr__(self) -> str:
        return self.value


# ------------------------------------------------------------------------------------

class Face(Enum):
    RIGHT = "R"
    LEFT = "L"
    UP = "U"
    DOWN = "D"
    FRONT = "F"
    BACK = "B"

    def __repr__(self) -> str:
        return f"{self.value}"

    @staticmethod
    def from_normal(normal: Vector) -> 'Face':
        if normal == X:
            return Face.RIGHT
        elif normal == -X:
            return Face.LEFT
        elif normal == Y:
            return Face.UP
        elif normal == -Y:
            return Face.DOWN
        elif normal == Z:
            return Face.FRONT
        elif normal == -Z:
            return Face.BACK
        else:
            raise ValueError(f'Invalid normal: {normal}')

    @property
    def normal(self) -> Vector:
        if self == Face.RIGHT:
            return X
        elif self == Face.LEFT:
            return -X
        elif self == Face.UP:
            return Y
        elif self == Face.DOWN:
            return -Y
        elif self == Face.FRONT:
            return Z
        elif self == Face.BACK:
            return -Z

    def rotated(self, axis: Vector, rotation: Rotation) -> 'Face':
        return Face.from_normal(self.normal.rotated(axis, rotation))

class TestFace(unittest.TestCase):
    def test_from_normal(self):
        self.assertEqual(Face.from_normal(X), Face.RIGHT)
        self.assertEqual(Face.from_normal(-X), Face.LEFT)
    
    def test_rotated(self):
        self.assertEqual(Face.RIGHT.rotated(X, Rotation.CLOCKWISE), Face.RIGHT)
        self.assertEqual(Face.FRONT.rotated(X, Rotation.CLOCKWISE), Face.UP)
        self.assertEqual(Face.DOWN.rotated(Y, Rotation.COUNTER_CLOCKWISE), Face.DOWN)
        self.assertEqual(Face.FRONT.rotated(Y, Rotation.COUNTER_CLOCKWISE), Face.RIGHT)
        self.assertEqual(Face.BACK.rotated(Z, Rotation.FLIP), Face.BACK)
        self.assertEqual(Face.UP.rotated(Z, Rotation.FLIP), Face.DOWN)


# ------------------------------------------------------------------------------------

class PieceKind(Enum):
    CENTER = "center"
    EDGE = "edge"
    CORNER = "corner"

class Piece:
    def __init__(self, position: Vector, colors: dict[Face, Color]):
        self.position = position
        self.colors = colors
        if len(colors) < 1 or len(colors) > 3:
            raise ValueError(f'Invalid piece: {colors}')

    def __repr__(self) -> str:
        return f'Piece({self.position}, {self.colors})'

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Piece):
            return False
        return self.position == other.position and self.colors == other.colors

    def __ne__(self, other: object) -> bool:
        return not self.__eq__(other)

    def facing(self, face: Face) -> bool:
        return face in self.colors

    def __getitem__(self, face: Face) -> Color:
        return self.colors[face]

    @property
    def kind(self) -> PieceKind:
        if len(self.colors) == 1:
            return PieceKind.CENTER
        elif len(self.colors) == 2:
            return PieceKind.EDGE
        elif len(self.colors) == 3:
            return PieceKind.CORNER

    def rotated(self, axis: Vector, rotation: Rotation) -> 'Piece':
        colors = dict(zip((face.rotated(axis, rotation) for face in self.colors.keys()), self.colors.values()))
        return Piece(self.position.rotated(axis, rotation), colors)


class TestPiece(unittest.TestCase):
    def test_init(self):
        piece = Piece(Vector(1, 0, 0), {Face.RIGHT: Color.RED})
        self.assertTrue(piece.facing(Face.RIGHT))
        self.assertFalse(piece.facing(Face.LEFT))

        self.assertEqual(piece[Face.RIGHT], Color.RED)
    
    def test_equality(self):
        piece = Piece(Vector(1, 0, 0), {Face.RIGHT: Color.RED})
        self.assertEqual(piece, Piece(Vector(1, 0, 0), {Face.RIGHT: Color.RED}))
        self.assertNotEqual(piece, Piece(Vector(0, 1, 0), {Face.UP: Color.WHITE}))
        self.assertNotEqual(piece, Piece(Vector(1, 0, 0), {Face.RIGHT: Color.ORANGE}))

    def test_kind(self):
        piece = Piece(Vector(1, 0, 0), {Face.RIGHT: Color.RED})
        self.assertEqual(piece.kind, PieceKind.CENTER)

        piece = Piece(Vector(1, 1, 0), {Face.RIGHT: Color.RED,
                                        Face.UP: Color.WHITE})
        self.assertEqual(piece.kind, PieceKind.EDGE)

        piece = Piece(TRF, {Face.RIGHT: Color.RED,
                            Face.UP: Color.WHITE,
                            Face.FRONT: Color.GREEN})
        self.assertEqual(piece.kind, PieceKind.CORNER)

    def test_rotated(self):
        piece = Piece(TRF, {
            Face.RIGHT: Color.RED,
            Face.UP: Color.WHITE,
            Face.FRONT: Color.GREEN,
        })
        self.assertEqual(piece.rotated(Z, Rotation.CLOCKWISE), Piece(DRF, {
            Face.DOWN: Color.RED,
            Face.RIGHT: Color.WHITE,
            Face.FRONT: Color.GREEN,
        }))

# ------------------------------------------------------------------------------------

class Sticker:
    def __init__(self, color: Color, piece: Piece) -> None:
        self.color = color
        self.piece = piece

# ------------------------------------------------------------------------------------

class Move(Enum):
    R = "R"
    L = "L"
    U = "U"
    D = "D"
    F = "F"
    B = "B"

    M = "M"
    E = "E"
    S = "S"

    x = "x"
    y = "y"
    z = "z"

    @property
    def axis(self) -> Vector:
        if self in [Move.R, Move.S, Move.x]:
            return X
        elif self in [Move.L]:
            return -X
        elif self == [Move.U, Move.M, Move.y]:
            return Y
        elif self == [Move.D]:
            return -Y
        elif self == [Move.F, Move.E, Move.z]:
            return Z
        elif self == Move.B:
            return -Z
        else:
            raise ValueError(f'Invalid move: {self}')

    def filter(self, position: Vector) -> bool:
        if self == Move.R:
            return position.x == 1
        elif self == Move.L:
            return position.x == -1
        elif self == Move.U:
            return position.y == 1
        elif self == Move.D:
            return position.y == -1
        elif self == Move.F:
            return position.z == 1
        elif self == Move.B:
            return position.z == -1
        elif self == Move.M:
            return position.x == 0
        elif self == Move.E:
            return position.y == 0
        elif self == Move.S:
            return position.z == 0
        elif self in [Move.x, Move.y, Move.z]:
            return True
        else:
            raise ValueError(f'Invalid move: {self}')

# ------------------------------------------------------------------------------------

class Cube:
    def __init__(self, pieces: list[Piece] = []):
        if not pieces:
            for x in [-1, 0, 1]:
                for y in [-1, 0, 1]:
                    for z in [-1, 0, 1]:
                        position = Vector(x, y, z)
                        if position == Vector(0, 0, 0):
                            continue

                        pieces.append(Piece(position, self.defaultColors(position)))
        self._pieces = pieces

    @staticmethod
    def defaultColors(position: Vector) -> dict[Face, Color]:
        colors = {}
        if position.x == 1:
            colors[Face.RIGHT] = Color.RED
        elif position.x == -1:
            colors[Face.LEFT] = Color.ORANGE
        if position.y == 1:
            colors[Face.UP] = Color.WHITE
        elif position.y == -1:
            colors[Face.DOWN] = Color.YELLOW
        if position.z == 1:
            colors[Face.FRONT] = Color.GREEN
        elif position.z == -1:
            colors[Face.BACK] = Color.BLUE

        return colors

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Cube):
            return False
        return self._pieces == other._pieces
    
    def pieces(self, filter: callable = None, facing: Face = None) -> list[Piece]:
        pieces = self._pieces

        if facing:
            pieces = [piece for piece in pieces if piece.facing(facing)]

        if filter:
            pieces = [piece for piece in pieces if filter(piece)]

        return pieces

    def stickers(self, filter: callable = None, facing: Face = None) -> list[tuple[Vector, Color]]:
    def apply(self, move: Move, prime: bool = False, twice: bool = False) -> 'Cube':
        axis = move.axis
        rotation = Rotation.FLIP if twice else Rotation.COUNTER_CLOCKWISE if prime else Rotation.CLOCKWISE
        pieces = [piece.rotated(axis, rotation) for piece in self._pieces if move.filter(piece.position)]
        return Cube(pieces)
    
    def dump(self):
        def print_face(*faces):
            pass

        up = self.pieces(facing=Face.UP)
        left = self.pieces(facing=Face.LEFT)
        front = self.pieces(facing=Face.FRONT)
        right = self.pieces(facing=Face.RIGHT)
        back = self.pieces(facing=Face.BACK)
        down = self.pieces(facing=Face.DOWN)

class TestCube(unittest.TestCase):
    def test_init(self):
        cube = Cube()
        self.assertEqual(cube, Cube())

    def test_move(self):
        cube = Cube()

# ------------------------------------------------------------------------------------

if __name__ == '__main__':

    TRF = Vector(1, 1, 1)
    DRF = Vector(1, -1, 1)
    DLF = Vector(-1, -1, 1)
    TLF = Vector(-1, 1, 1)
    TRB = Vector(1, 1, -1)
    DRB = Vector(1, -1, -1)
    DLB = Vector(-1, -1, -1)
    TLB = Vector(-1, 1, -1)

    cube = Cube()

    unittest.main()
