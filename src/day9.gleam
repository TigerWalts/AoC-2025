import gleam/bool
import gleam/int
import gleam/list
import gleam/order
import gleam/string

type Pos {
  Pos(x: Int, y: Int)
}

type Pair {
  Pair(a: Pos, b: Pos, area: Int)
}

pub fn part_1(input: String) -> Int {
  let assert Ok(Pair(area:, ..)) =
    parse(input)
    |> list.combination_pairs
    |> list.map(tuple_pair_to_pair_area)
    |> list.sort(cmp_pair_by_area)
    |> list.reverse
    |> list.first
  area
}

pub fn part_2(input: String) -> Int {
  let red_tiles = parse(input)

  let edges =
    list.append(red_tiles, list.take(red_tiles, 1)) |> list.window_by_2

  let pairs =
    list.combination_pairs(red_tiles)
    |> list.map(tuple_pair_to_pair_area)
    |> list.sort(cmp_pair_by_area)
    |> list.reverse

  process(pairs, edges)
}

fn parse(input: String) -> List(Pos) {
  string.split(input, on: "\n")
  |> list.map(fn(line) {
    let assert [x, y] =
      string.split(line, on: ",")
      |> list.map(fn(nums) {
        let assert Ok(val) = int.parse(nums)
        val
      })
    Pos(x:, y:)
  })
}

fn tuple_pair_to_pair_area(tuple_pair: #(Pos, Pos)) -> Pair {
  let #(a, b) = tuple_pair
  Pair(
    a:,
    b:,
    area: { int.absolute_value({ a.x - b.x }) + 1 }
      * { int.absolute_value({ a.y - b.y }) + 1 },
  )
}

fn cmp_pair_by_area(a: Pair, b: Pair) -> order.Order {
  int.compare(a.area, b.area)
}

fn process(pairs: List(Pair), edges: List(#(Pos, Pos))) -> Int {
  case pairs {
    [] -> panic as "Oh no!"
    [pair, ..pairs] -> {
      let box = pair_to_box(pair)
      case edge_traverses(edges, box) {
        False -> box.area
        True -> process(pairs, edges)
      }
    }
  }
}

fn pair_to_box(pair: Pair) -> Pair {
  Pair(
    a: Pos(int.min(pair.a.x, pair.b.x), int.min(pair.a.y, pair.b.y)),
    b: Pos(int.max(pair.a.x, pair.b.x), int.max(pair.a.y, pair.b.y)),
    area: pair.area,
  )
}

fn edge_traverses(edges: List(#(Pos, Pos)), box: Pair) -> Bool {
  case edges {
    [] -> False
    [edge, ..edges] -> {
      case bool.or(edge_spans_box(edge, box), edge_node_in_box(edge, box)) {
        True -> True
        False -> edge_traverses(edges, box)
      }
    }
  }
}

fn edge_spans_box(edge: #(Pos, Pos), box: Pair) -> Bool {
  case { edge.0 }.x == { edge.1 }.x {
    True ->
      bool.and({ edge.0 }.x > box.a.x, { edge.0 }.x < box.b.x)
      |> bool.and(int.min({ edge.0 }.y, { edge.1 }.y) <= box.a.y)
      |> bool.and(int.max({ edge.0 }.y, { edge.1 }.y) >= box.b.y)
    False ->
      bool.and({ edge.0 }.y > box.a.y, { edge.0 }.y < box.b.y)
      |> bool.and(int.min({ edge.0 }.x, { edge.1 }.x) <= box.a.x)
      |> bool.and(int.max({ edge.0 }.x, { edge.1 }.x) >= box.b.x)
  }
}

fn edge_node_in_box(edge: #(Pos, Pos), box: Pair) -> Bool {
  case { edge.0 }.x == { edge.1 }.x {
    True ->
      bool.and({ edge.0 }.x > box.a.x, { edge.0 }.x < box.b.x)
      |> bool.and(bool.or(
        bool.and({ edge.0 }.y > box.a.y, { edge.0 }.y < box.b.y),
        bool.and({ edge.1 }.y > box.a.y, { edge.1 }.y < box.b.y),
      ))
    False ->
      bool.and({ edge.0 }.y > box.a.y, { edge.0 }.y < box.b.y)
      |> bool.and(bool.or(
        bool.and({ edge.0 }.x > box.a.x, { edge.0 }.x < box.b.x),
        bool.and({ edge.1 }.x > box.a.x, { edge.1 }.x < box.b.x),
      ))
  }
}
