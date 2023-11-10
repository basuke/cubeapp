from enum import Enum
from .cube import *

class Permutations(Enum):
    T = "R U R' U' R' F R2 U' R' U' R U R' F'"
    J = "R U R' F' R U R' U' R' F R2 U' R' U'"
    Y = "F R U' R' U' R U R' F' R U R' U' R' F R F'"
    U = "R U R' U R' F R2 U' R' U' R U R' F'"
    A = "R U R' F' R U2 R' U2 R' F R U R U2 R'"
    G = "R2 U R' U R' U' R U' R2 F R F'"
    F = "R' U2 R U2 R' F R U R' U' R' F' R2 U'"
    V = "R' U R' U' R' F R2 U' R' U' R U R' F'"
    W = "R U2 R' U' R U R' F' R U R' U' R' F R2 U'"
    Z = "R U R' U' M' U R U' r'"
    N = "R U2 R' U' R U R' F' R U R' U' R' F R F'"
    E = "R U R' U' R' F R U R' U' R' F' R2 U' R'"
    H = "R U R' U R D R' U' R D' R' U2 R' U2 R U' R'"

class Solver:
    cube: Cube

    def __init__(self, cube: Cube):
        self.cube = cube

    def solve(self):
        return Permutations[self.scramble].value