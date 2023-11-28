from enum import Enum
from itertools import combinations
import math
import unittest
from termcolor import colored

class Rotation(Enum):
    CLOCKWISE = -90
    COUNTER_CLOCKWISE = 90
    FLIP = 180

    @property
    def reversed(self) -> 'Rotation':
        if self == CLOCKWISE:
            return COUNTER_CLOCKWISE
        elif self == COUNTER_CLOCKWISE:
            return CLOCKWISE
        else:
            return self

    def rotate(self, a, b):
        if self == CLOCKWISE:
            return b, -a
        elif self == COUNTER_CLOCKWISE:
            return -b, a
        else:
            return -a, -b

CLOCKWISE = Rotation.CLOCKWISE
COUNTER_CLOCKWISE = Rotation.COUNTER_CLOCKWISE
FLIP = Rotation.FLIP

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
        if isinstance(other, Vector):
            return self.x == other.x and self.y == other.y and self.z == other.z
        if isinstance(other, tuple):
            return self.x == other[0] and self.y == other[1] and self.z == other[2]
        return False

    def __bool__(self) -> bool:
        return self.x or self.y or self.z

    def __ne__(self, other: object) -> bool:
        return not self.__eq__(other)

    def __neg__(self) -> 'Vector':
        return Vector(-self.x, -self.y, -self.z)

    def __add__(self, other: 'Vector') -> 'Vector':
        return Vector(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other: 'Vector') -> 'Vector':
        return Vector(self.x - other.x, self.y - other.y, self.z - other.z)

    def __hash__(self) -> int:
        return hash((self.x, self.y, self.z))

    @property
    def length(self) -> float:
        return math.sqrt(self.length2)

    @property
    def length2(self) -> float:
        return self.x ** 2 + self.y ** 2 + self.z ** 2

    def is_neighbor(self, other: 'Vector') -> bool:
        return (self - other).length == 1

    @property
    def values(self) -> tuple[int, int, int]:
        return (self.x, self.y, self.z)

    def rotated(self, axis: 'Vector', rotation: Rotation) -> 'Vector':
        x, y, z = self.values

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

# Corners
CORNER_RUF = Vector(1, 1, 1)
CORNER_RUB = Vector(1, 1, -1)
CORNER_RDF = Vector(1, -1, 1)
CORNER_RDB = Vector(1, -1, -1)
CORNER_LUF = Vector(-1, 1, 1)
CORNER_LUB = Vector(-1, 1, -1)
CORNER_LDF = Vector(-1, -1, 1)
CORNER_LDB = Vector(-1, -1, -1)

# Edges
EDGE_RU = Vector(1, 1, 0)
EDGE_RF = Vector(1, 0, 1)
EDGE_RB = Vector(1, 0, -1)
EDGE_RD = Vector(1, -1, 0)
EDGE_UF = Vector(0, 1, 1)
EDGE_UB = Vector(0, 1, -1)
EDGE_DF = Vector(0, -1, 1)
EDGE_DB = Vector(0, -1, -1)
EDGE_LU = Vector(-1, 1, 0)
EDGE_LF = Vector(-1, 0, 1)
EDGE_LB = Vector(-1, 0, -1)
EDGE_LD = Vector(-1, -1, 0)

# Centers
CENTER_R = Vector(1, 0, 0)
CENTER_U = Vector(0, 1, 0)
CENTER_F = Vector(0, 0, 1)
CENTER_B = Vector(0, 0, -1)
CENTER_D = Vector(0, -1, 0)
CENTER_L = Vector(-1, 0, 0)

class TestVector(unittest.TestCase):
    def test_vector(self):
        self.assertEqual(X, Vector(1, 0, 0))

    def test_negative(self):
        self.assertEqual(-X, Vector(-1, 0, 0))

    def test_rounded(self):
        self.assertEqual(Vector(0, 1.1, 0).rounded, Y)

    def test_rotated(self):
        self.assertEqual(X.rotated(Z, CLOCKWISE), -Y)
        self.assertEqual(X.rotated(Y, COUNTER_CLOCKWISE), -Z)

        self.assertEqual(Y.rotated(X, FLIP), -Y)
        self.assertEqual(Y.rotated(Z, FLIP), -Y)
        self.assertEqual(Y.rotated(Y, FLIP), Y)

        self.assertEqual(Z.rotated(X, CLOCKWISE), Y)

    def test_equal(self):
        self.assertEqual(X, Vector(1, 0, 0))
        self.assertEqual(X, (1, 0, 0))

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

    def __str__(self) -> str:
        return self.value

    @property
    def symbol(self) -> str:
        return self.value[0]

    @property
    def coloredSymbol(self) -> str:
        return colored(self.symbol, self.termcolor)

    @property
    def termcolor(self) -> str:
        if self == RED:
            return 'light_magenta'
        elif self == ORANGE:
            return 'light_red'
        elif self == WHITE:
            return 'white'
        elif self == YELLOW:
            return 'yellow'
        elif self == GREEN:
            return 'green'
        elif self == BLUE:
            return 'blue'

RED = Color.RED
ORANGE = Color.ORANGE
WHITE = Color.WHITE
YELLOW = Color.YELLOW
GREEN = Color.GREEN
BLUE = Color.BLUE

# ------------------------------------------------------------------------------------

class Face(Enum):
    RIGHT = "R"
    LEFT = "L"
    UP = "U"
    DOWN = "D"
    FRONT = "F"
    BACK = "B"

    def __repr__(self) -> str:
        return self.value

    def __str__(self) -> str:
        return self.value

    @staticmethod
    def from_normal(normal: Vector) -> 'Face':
        if normal == X:
            return RIGHT
        elif normal == -X:
            return LEFT
        elif normal == Y:
            return UP
        elif normal == -Y:
            return DOWN
        elif normal == Z:
            return FRONT
        elif normal == -Z:
            return BACK
        else:
            raise ValueError(f'Invalid normal: {normal}')

    @property
    def normal(self) -> Vector:
        if self == RIGHT:
            return X
        elif self == LEFT:
            return -X
        elif self == UP:
            return Y
        elif self == DOWN:
            return -Y
        elif self == FRONT:
            return Z
        elif self == BACK:
            return -Z

    @property
    def neighbors(self) -> list['Face']:
        if self == RIGHT or self == LEFT:
            return [UP, FRONT, DOWN, BACK]
        elif self == UP or self == DOWN:
            return [BACK, RIGHT, FRONT, LEFT]
        else:
            return [UP, RIGHT, DOWN, LEFT]

    def rotated(self, axis: Vector, rotation: Rotation) -> 'Face':
        return Face.from_normal(self.normal.rotated(axis, rotation))

UP = Face.UP
DOWN = Face.DOWN
LEFT = Face.LEFT
RIGHT = Face.RIGHT
FRONT = Face.FRONT
BACK = Face.BACK

class TestFace(unittest.TestCase):
    def test_from_normal(self):
        self.assertEqual(Face.from_normal(X), RIGHT)
        self.assertEqual(Face.from_normal(-X), LEFT)
    
    def test_rotated(self):
        self.assertEqual(RIGHT.rotated(X, CLOCKWISE), RIGHT)
        self.assertEqual(FRONT.rotated(X, CLOCKWISE), UP)
        self.assertEqual(DOWN.rotated(Y, COUNTER_CLOCKWISE), DOWN)
        self.assertEqual(FRONT.rotated(Y, COUNTER_CLOCKWISE), RIGHT)
        self.assertEqual(BACK.rotated(Z, FLIP), BACK)
        self.assertEqual(UP.rotated(Z, FLIP), DOWN)


# ------------------------------------------------------------------------------------

class PieceKind(Enum):
    CENTER = "center"
    EDGE = "edge"
    CORNER = "corner"

CENTER = PieceKind.CENTER
EDGE = PieceKind.EDGE
CORNER = PieceKind.CORNER

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

    def __hash__(self):
        return hash((self.position, tuple(self.colors.items())))

    def facing(self, face: Face) -> bool:
        return face in self.colors

    def __getitem__(self, face: Face) -> Color|None:
        return self.colors.get(face, None)

    def hasSome(self, *colors: Color) -> bool:
        all_colors = self.colors.values()
        return any(color in all_colors for color in colors)

    def hasAll(self, *colors: Color) -> bool:
        all_colors = self.colors.values()
        return all(color in all_colors for color in colors)

    def hasExact(self, *colors: Color) -> bool:
        return len(self.colors) == len(colors) and self.hasAll(*colors)

    def is_at(self, position: Vector|tuple[int, int, int]) -> bool:
        return self.position == position

    def is_neighbor(self, other: 'Piece') -> bool:
        return self.position.is_neighbor(other.position)

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
        piece = Piece(Vector(1, 0, 0), {RIGHT: RED})
        self.assertTrue(piece.facing(RIGHT))
        self.assertFalse(piece.facing(LEFT))

        self.assertEqual(piece[RIGHT], RED)
    
    def test_equality(self):
        piece = Piece(Vector(1, 0, 0), {RIGHT: RED})
        self.assertEqual(piece, Piece(Vector(1, 0, 0), {RIGHT: RED}))
        self.assertNotEqual(piece, Piece(Vector(0, 1, 0), {UP: WHITE}))
        self.assertNotEqual(piece, Piece(Vector(1, 0, 0), {RIGHT: ORANGE}))

    def test_kind(self):
        piece = Piece(Vector(1, 0, 0), {RIGHT: RED})
        self.assertEqual(piece.kind, CENTER)

        piece = Piece(Vector(1, 1, 0), {RIGHT: RED,
                                        UP: WHITE})
        self.assertEqual(piece.kind, EDGE)

        piece = Piece(CORNER_RUF, {RIGHT: RED,
                            UP: WHITE,
                            FRONT: GREEN})
        self.assertEqual(piece.kind, CORNER)

    def test_rotated(self):
        piece = Piece(CORNER_RUF, {
            RIGHT: RED,
            UP: WHITE,
            FRONT: GREEN,
        })
        self.assertEqual(
            piece.rotated(Z, CLOCKWISE),
            Piece(CORNER_RDF, {
                DOWN: RED,
                RIGHT: WHITE,
                FRONT: GREEN,
            })
        )

# ------------------------------------------------------------------------------------

class Sticker:
    piece: Piece
    face: Face

    def __init__(self, piece: Piece, face: Face) -> None:
        self.piece = piece
        self.face = face

    @property
    def color(self):
        return self.piece[self.face]

    @property
    def index(self):
        x, y, z = self.piece.position.values

        if self.face == UP:
            return (z + 1) * 3 + (x + 1)
        elif self.face == DOWN:
            return (-z + 1) * 3 + (x + 1)
        elif self.face == FRONT:
            return (-y + 1) * 3 + (x + 1)
        elif self.face == BACK:
            return (-y + 1) * 3 + (-x + 1)
        elif self.face == LEFT:
            return (-y + 1) * 3 + (z + 1)
        else:
            return (-y + 1) * 3 + (-z + 1)

    def __repr__(self) -> str:
        return f"{self.color} @ {self.piece.position}"

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
        if self in [R, x]:
            return X
        elif self in [L, M]:
            return -X
        elif self in [U, y]:
            return Y
        elif self in [D, E]:
            return -Y
        elif self in [F, S, z]:
            return Z
        elif self in [B]:
            return -Z
        else:
            raise ValueError(f'Invalid move: {self}')

    def filter(self, piece: Piece) -> bool:
        if self == R:
            return piece.position.x == 1
        elif self == L:
            return piece.position.x == -1
        elif self == U:
            return piece.position.y == 1
        elif self == D:
            return piece.position.y == -1
        elif self == F:
            return piece.position.z == 1
        elif self == B:
            return piece.position.z == -1
        elif self == M:
            return piece.position.x == 0
        elif self == E:
            return piece.position.y == 0
        elif self == S:
            return piece.position.z == 0
        else:
            return True

    @staticmethod
    def parse(moveStr: str) -> list[tuple['Move', bool, bool]]:
        while True:
            moveStr = moveStr.lstrip()
            if not moveStr:
                break

            move, moveStr = Move(moveStr[0]), moveStr[1:]

            prime = moveStr and moveStr[0] == "'"
            if prime:
                moveStr = moveStr[1:]

            twice = moveStr and moveStr[0] == "2"
            if twice:
                moveStr = moveStr[1:]

            yield move, prime, twice

R = Move.R
L = Move.L
U = Move.U
D = Move.D
F = Move.F
B = Move.B
x = Move.x
y = Move.y
z = Move.z
E = Move.E
M = Move.M
S = Move.S

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
            colors[RIGHT] = RED
        elif position.x == -1:
            colors[LEFT] = ORANGE
        if position.y == 1:
            colors[UP] = WHITE
        elif position.y == -1:
            colors[DOWN] = YELLOW
        if position.z == 1:
            colors[FRONT] = GREEN
        elif position.z == -1:
            colors[BACK] = BLUE

        return colors

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Cube):
            return False
        return self._pieces == other._pieces

    def __hash__(self):
        return hash(piece for piece in self._pieces)

    def pieces(self, *, filter: callable = None, facing: Face = None, colors: list[Color] = None, kind: PieceKind = None) -> list[Piece]:
        def match(piece: Piece) -> bool:
            if colors and not piece.hasExact(*colors):
                return False
            if filter and not filter(piece):
                return False
            if facing and not piece.facing(facing):
                return False
            if kind and piece.kind != kind:
                return False
            return True

        pieces = [piece for piece in self._pieces if match(piece)]
        return sorted(pieces, key=lambda piece: piece.position.values)

    def piece(self, at: Vector = None, *, filter: callable = None, colors: list[Color] = None) -> Piece|None:
        for piece in self._pieces:
            if at and piece.is_at(at):
                return piece
            if filter and filter(piece):
                return piece
            if colors and piece.hasExact(*colors):
                return piece
        return None

    def stickers(self, filter: callable = None, facing: Face = None, color: Color = None) -> list[Sticker]:
        def all_stickers():
            for piece in self._pieces:
                for face, _ in piece.colors.items():
                    yield Sticker(piece, face)

        def match(sticker: Sticker) -> bool:
            if filter and not filter(sticker):
                return False
            if facing and sticker.face != facing:
                return False
            if color and sticker.color != color:
                return False
            return True

        return sorted([
            sticker
            for sticker in all_stickers()
            if match(sticker)
        ], key=lambda sticker: sticker.piece.position.values)

    def apply(self, move: Move|str, prime: bool = False, twice: bool = False) -> 'Cube':
        if isinstance(move, str):
            cube = self
            for move, prime, twice in Move.parse(move):
                cube = cube.apply(move, prime, twice)
            return cube

        axis = move.axis
        rotation = FLIP if twice else COUNTER_CLOCKWISE if prime else CLOCKWISE
        moved = [piece.rotated(axis, rotation) for piece in self.pieces(filter=move.filter)]
        not_moved = self.pieces(filter=lambda piece: not move.filter(piece))
        return Cube(moved + not_moved)
    
    def as2D(self, colored: bool = True) -> str:
        def row_to_str(stickers: list[Sticker]) -> str:
            return "".join(
                sticker.color.coloredSymbol if colored else sticker.color.symbol
                for sticker in stickers
            )

        def rows(stickers: list[Sticker]) -> list[list[Sticker]]:
            while stickers:
                yield stickers[:3]
                stickers = stickers[3:]

        def gap() -> list[str]:
            return [
                "   ",
                "   ",
                "   ",
            ]

        def face_str(face: Face) -> list[str]:
            stickers = sorted(self.stickers(facing=face), key=lambda s: s.index)
            return [row_to_str(row) for row in rows(stickers)]

        def merge(*faces: list[str]) -> list[str]:
            return "\n".join(
                " ".join(lines)
                for lines in zip(*faces)
            )

        return "\n".join([
            merge(gap(), face_str(UP)),
            merge(*(face_str(face) for face in [LEFT, FRONT, RIGHT, BACK])),
            merge(gap(), face_str(DOWN))
        ])

    def __repr__(self) -> str:
        return self.as2D() + f"\nentropy: {self.entropy}"

    @property
    def entropy(self) -> float:
        def entropyOf(color: Color) -> float:
            stickers = self.stickers(color=color)
            result = sum(entropyOfStickers(s1, s2) for s1, s2 in combinations(stickers, 2))
            return result

        def entropyOfStickers(s1: Sticker, s2: Sticker) -> float:
            p1 = s1.piece.position
            p2 = s2.piece.position
            result = (p1 - p2).length - 1
            return result

        return sum(entropyOf(color) for color in Color)

    def dump(self):
        print(self.as2D())

class TestCube(unittest.TestCase):
    def test_init(self):
        cube = Cube()
        self.assertEqual(cube, Cube())

    def test_move(self):
        cube = Cube().apply("RUR'U'")
        self.assertTrue(cube.piece(at=(1,1,1)).hasExact(RED, GREEN, YELLOW))

    def test_piece(self):
        cube = Cube()
        piece = cube.piece(colors=[RED, GREEN, YELLOW])
        self.assertTrue(piece.hasExact(RED, GREEN, YELLOW))
        self.assertEqual(piece.position, CORNER_RDF)

    def test_entropy(self):
        cube = Cube()
        self.assertEqual(cube.entropy, 0)

# ------------------------------------------------------------------------------------

if __name__ == '__main__':

    cube = Cube()

    unittest.main()
