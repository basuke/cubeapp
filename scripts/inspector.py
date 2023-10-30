from cube import *
from enum import Enum
import unittest

class CachedQuery:
    def __init__(self, *common_args):
        self.cache = {}
        self.common_args = list(common_args)

    def __call__(self, query, *args):
        name = str(query)

        if name not in self.cache:
            self.cache[name] = {}

        cache = self.cache[name]
        if args not in self.cache:
            cache[args] = query(*(self.common_args + list(args)))
        return cache[args]

class Inspector:
    cube: Cube

    def __init__(self, cube: Cube):
        self.cube = cube
        self._cache = CachedQuery(cube)

    def is_solved(self) -> bool:
        return all(self.is_face_solved(face) for face in Face)

    def is_face_solved(self, face: Face, *, side: bool = False) -> bool:
        return self._cache(is_face_solved, face, side)

    def solved_faces(self, *, side: bool = False) -> dict[Face, Color]:
        return dict((face, self.get_color(face)) for face in Face if self.is_face_solved(face, side=side))

    def get_color(self, face: Face) -> Color:
        return self._cache(get_color, face)
    
    def is_any_2layer_solved(self) -> Face|None:
        for face in self.solved_faces(side=True):
            if self.is_2layer_solved_for(face):
                return face
        return None
    
    def is_2layer_solved_for(self, face: Face) -> bool:
        return self._cache(is_2layer_solved_for, face)


def get_color(cube: Cube, face: Face) -> Color:
    pieces = cube.pieces(facing=face, kind=CENTER)
    return pieces.pop()[face]

def is_face_solved(cube: Cube, face: Face, side: bool) -> bool:
    pieces = cube.pieces(facing=face)
    if not same_color_on_face(pieces, face):
        return False

    return not side or all(
        same_color_on_face(pieces, neighbor)
        for neighbor in face.neighbors
    )

def same_color_on_face(pieces: list[Piece], face: Face) -> bool:
    colors = set(piece[face] for piece in pieces if piece[face] is not None)
    return len(colors) == 1

def are_pieces_neighbors(piece1: Piece, piece2: Piece) -> bool:
    return len(piece1.position - piece2.postion) == 1

def is_2layer_solved_for(cube: Cube, face: Face) -> bool:
    """
    Checks if the 2-layer is solved for the given face.
    Assume the face is already solved.
    """
    pieces = set()
    for piece in cube.pieces(facing=face):
        pieces.add(piece)
        pieces.update(cube.pieces(filter=lambda p: piece.is_neighbor(p)))

    for neighbor_face in face.neighbors:
        pieces_on_face = [piece for piece in pieces if piece[neighbor_face]]
        if not same_color_on_face(pieces_on_face, neighbor_face):
            return False

    return True

class TestInspector(unittest.TestCase):
    def test_is_solved(self):
        cube = Cube()
        inspector = Inspector(cube)
        self.assertTrue(inspector.is_solved())

        cube = cube.apply(R)
        inspector = Inspector(cube)
        self.assertFalse(inspector.is_solved())

    def test_is_face_solved(self):
        cube = Cube()
        inspector = Inspector(cube)
        self.assertTrue(inspector.is_face_solved(Face.UP))

        cube = cube.apply(R)
        inspector = Inspector(cube)
        self.assertFalse(inspector.is_face_solved(Face.UP))

    def test_is_any_2layer_solved(self):
        cube = Cube().apply(R)
        inspector = Inspector(cube)
        self.assertTrue(inspector.is_any_2layer_solved())

        cube = cube.apply(U)
        inspector = Inspector(cube)
        self.assertFalse(inspector.is_any_2layer_solved())

# ------------------------------------------------------------------------------------

if __name__ == '__main__':

    cube = Cube().apply("R U' R U R U R U' R' U' R2")
    inspector = Inspector(cube)
    unittest.main()
