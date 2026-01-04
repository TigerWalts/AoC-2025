import gleam/list
import gleam/set
import gleam/string

type Tile {
  Air
  ActivePrism
  Beam
  Prism
  Source
}

pub fn part_1(input: String) -> Int {
  let assert [first, ..rows] = parse(input)
  process_1(rows, first, 0)
}

fn process_1(rows: List(List(Tile)), prev: List(Tile), count: Int) -> Int {
  case rows {
    [] -> count
    [next, ..rest] -> {
      let #(new_prev, splits) = propogate(prev, next)
      process_1(rest, new_prev, count + splits)
    }
  }
}

fn propogate(prev: List(Tile), next: List(Tile)) -> #(List(Tile), Int) {
  let illuminated_next =
    list.map2(prev, next, fn(a, b) {
      case a, b {
        Air, b -> b
        ActivePrism, b -> b
        Beam, Air -> Beam
        Beam, Prism -> ActivePrism
        Prism, b -> b
        Source, Air -> Beam
        Source, Prism -> ActivePrism
        a, b ->
          panic as {
            "Unexpected tile "
            <> tile_to_string(a)
            <> " over tile "
            <> tile_to_string(b)
          }
      }
    })
  let last_idx = list.length(illuminated_next) - 1
  let #(split_count, spread_ids) =
    list.index_fold(illuminated_next, #(0, set.new()), fn(acc, tile, idx) {
      case acc, tile, idx == 0, idx == last_idx {
        #(count, ids), ActivePrism, True, True -> #(count + 1, ids)
        #(count, ids), ActivePrism, True, False -> #(
          count + 1,
          set.insert(ids, idx + 1),
        )
        #(count, ids), ActivePrism, False, True -> #(
          count + 1,
          set.insert(ids, idx - 1),
        )
        #(count, ids), ActivePrism, False, False -> #(
          count + 1,
          ids |> set.insert(idx - 1) |> set.insert(idx + 1),
        )
        acc, _, _, _ -> acc
      }
    })
  let spread_next =
    list.index_map(illuminated_next, fn(tile, idx) {
      case tile, set.contains(spread_ids, idx) {
        Air, True -> Beam
        tile, _ -> tile
      }
    })
  #(spread_next, split_count)
}

fn tile_to_string(tile: Tile) -> String {
  case tile {
    ActivePrism -> "ActivePrism"
    Air -> "Air"
    Beam -> "Beam"
    Prism -> "Prism"
    Source -> "Source"
  }
}

pub fn part_2(input: String) -> Int {
  todo
}

fn parse(input: String) -> List(List(Tile)) {
  string.split(input, on: "\n")
  |> list.map(fn(line) { parse_line(line, []) })
}

fn parse_line(line: String, acc: List(Tile)) -> List(Tile) {
  case line {
    "" -> list.reverse(acc)
    "." <> rest -> parse_line(rest, [Air, ..acc])
    "S" <> rest -> parse_line(rest, [Source, ..acc])
    "^" <> rest -> parse_line(rest, [Prism, ..acc])
    _ -> panic as { "Invalid next character: " <> line }
  }
}
