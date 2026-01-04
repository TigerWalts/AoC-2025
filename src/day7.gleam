import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

type Tile {
  Air(Int)
  ActivePrism(Int)
  Beam(Int)
  Prism(Int)
  Source(Int)
}

pub fn part_1(input: String) -> Int {
  let assert [first, ..rows] = parse(input)
  process_1(rows, first, 0)
}

pub fn part_2(input: String) -> Int {
  let assert [first, ..rows] = parse(input)
  process_2(rows, first, 1)
}

fn parse(input: String) -> List(List(Tile)) {
  string.split(input, on: "\n")
  |> list.map(fn(line) { parse_line(line, []) })
}

fn parse_line(line: String, acc: List(Tile)) -> List(Tile) {
  case line {
    "" -> list.reverse(acc)
    "." <> rest -> parse_line(rest, [Air(0), ..acc])
    "S" <> rest -> parse_line(rest, [Source(1), ..acc])
    "^" <> rest -> parse_line(rest, [Prism(0), ..acc])
    _ -> panic as { "Invalid next character: " <> line }
  }
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

fn process_2(rows: List(List(Tile)), prev: List(Tile), count: Int) -> Int {
  case rows {
    [] ->
      list.fold(prev, 0, fn(acc, tile) {
        case tile {
          Beam(t) -> acc + t
          _ -> acc
        }
      })
    [next, ..rest] -> {
      let #(new_prev, _) = propogate(prev, next)
      process_2(rest, new_prev, count)
    }
  }
}

fn propogate(prev: List(Tile), next: List(Tile)) -> #(List(Tile), Int) {
  let illuminated_next =
    list.map2(prev, next, fn(a, b) {
      case a, b {
        Air(0), b -> b
        ActivePrism(_), b -> b
        Beam(t), Air(0) -> Beam(t)
        Beam(t), Prism(0) -> ActivePrism(t)
        Prism(0), b -> b
        Source(1), Air(0) -> Beam(1)
        Source(1), Prism(0) -> ActivePrism(1)
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
    list.index_fold(illuminated_next, #(0, dict.new()), fn(acc, tile, idx) {
      case acc, tile, idx == 0, idx == last_idx {
        #(count, ids), ActivePrism(_), True, True -> #(count + 1, ids)
        #(count, ids), ActivePrism(t), True, False -> #(
          count + 1,
          update_ids(ids, idx + 1, t),
        )
        #(count, ids), ActivePrism(t), False, True -> #(
          count + 1,
          update_ids(ids, idx - 1, t),
        )
        #(count, ids), ActivePrism(t), False, False -> #(
          count + 1,
          ids |> update_ids(idx - 1, t) |> update_ids(idx + 1, t),
        )
        acc, _, _, _ -> acc
      }
    })
  let spread_next =
    list.index_map(illuminated_next, fn(tile, idx) {
      case tile, dict.get(spread_ids, idx) {
        Air(0), Ok(t) -> Beam(t)
        Beam(t), Ok(v) -> Beam(t + v)
        _, _ -> tile
      }
    })
  #(spread_next, split_count)
}

fn update_ids(ids: dict.Dict(Int, Int), idx: Int, t: Int) -> dict.Dict(Int, Int) {
  dict.upsert(ids, idx, fn(opt) {
    case opt {
      None -> t
      Some(v) -> v + t
    }
  })
}

fn tile_to_string(tile: Tile) -> String {
  case tile {
    ActivePrism(t) -> "ActivePrism(" <> int.to_string(t) <> ")"
    Air(t) -> "Air(" <> int.to_string(t) <> ")"
    Beam(t) -> "Beam(" <> int.to_string(t) <> ")"
    Prism(t) -> "Prism(" <> int.to_string(t) <> ")"
    Source(t) -> "Source(" <> int.to_string(t) <> ")"
  }
}
