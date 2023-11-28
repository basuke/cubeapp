from enum import Enum
from cube import *
from inspector import *

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

class Node:
    def __init__(self, state, depth = 0, parent=None, move=None):
        self.state = state
        self.depth = depth
        self.parent = parent
        self.move = move

    def __eq__(self, other):
        return self.state == other.state

    def __hash__(self):
        return hash(self.state)

    @property
    def moves(self):
        if self.move is None:
            return []

        return ([] if self.parent is None else self.parent.moves) + [self.move]

class Searcher:
    explored: set[Node]
    frontier: list[Node]
    is_goal = lambda s: False
    applyer = lambda s: s
    moves: set
    explore_count: int

    def __init__(self, *, is_goal: callable, moves: set, applier: callable):
        self.is_goal = is_goal
        self.applyer = applier
        self.moves = moves

    def search(self, state, max_depth=10) -> Node|None:
        self.frontier = [Node(state, max_depth)]
        self.explored = set()
        self.explore_count = 0

        while self.frontier:
            node = self.frontier.pop(0)
            self.explore_count += 1

            if self.is_goal(node.state):
                return node

            self.explored.add(node)

            depth = node.depth - 1
            if depth >= 0:
                for move in self.moves:
                    moved_node = Node(self.applyer(node.state, move), depth, node, move)
                    if moved_node not in self.explored:
                        self.frontier.append(moved_node)

        return None

all_moves = [
    "R", "R'", "R2",
    "L", "L'", "L2",
    "U", "U'", "U2",
    "D", "D'", "D2",
    "F", "F'", "F2",
    "B", "B'", "B2",
    "M", "M'", "M2",
    "E", "E'", "E2",
    "S", "S'", "S2",
    "x", "x'", "x2",
    "y", "y'", "y2",
    "z", "z'", "z2",
]

all_moves = [
    "R", "R'", "R2",
    "L", "L'", "L2",
    "U", "U'", "U2",
    "D", "D'", "D2",
    "F", "F'", "F2",
    "B", "B'", "B2",
    # "R L'", "R' L", "R2 L2",
    # "U D'", "U' D", "U2 D2",
    # "F B'", "F' B", "F2 B2",
]

all_moves = [
    "R", "R'",
    "L", "L'",
    "U", "U'",
    "D", "D'",
    "F", "F'",
    "B", "B'",
]

class CubeSearcher(Searcher):
    def __init__(self):
        def is_solved(cube):
            inspector = Inspector(cube)
            return inspector.is_solved()

        super().__init__(is_goal=is_solved, moves=all_moves, applier=lambda cube, move: cube.apply(move))

if __name__ == '__main__':
    searcher = CubeSearcher()
    cube = Cube().apply("E2 M2")
    print(cube)
    result = searcher.search(cube, 8)
    if result is None:
        print("Not found")
    else:
        print(" ".join(result.moves))
    print(f"explored: {searcher.explore_count}")
