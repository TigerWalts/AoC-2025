import gleam/bool
import gleam/list
import gleam/string
import splitter

type Tile {
  Empty
  Roll
}

pub fn part_1(input) -> Int {
  parse(input)
  |> find_free_rolls
  |> list.length
}

pub fn part_2(input) -> Int {
  parse(input)
  |> do_part_2(0)
}

fn do_part_2(rows: List(List(Tile)), count) -> Int {
  case find_free_rolls(rows) {
    [] -> count
    free_rolls ->
      rows
      |> remove_rolls([], free_rolls, -1)
      |> do_part_2(count + list.length(free_rolls))
  }
}

fn parse(input: String) -> List(List(Tile)) {
  let on_newline = splitter.new(["\n", "\r\n"])
  do_parse(input, [], on_newline)
}

fn do_parse(
  input: String,
  output: List(List(Tile)),
  on_newline: splitter.Splitter,
) -> List(List(Tile)) {
  let #(row, _, rest) = splitter.split(on_newline, input)
  let tiles =
    string.to_graphemes(row)
    |> list.fold([Empty], fn(acc, char) {
      case char {
        "." -> [Empty, ..acc]
        "@" -> [Roll, ..acc]
        c -> panic as { "Unexpected character: " <> c }
      }
    })
    |> list.prepend(Empty)
    |> list.reverse

  let output = case output {
    [] -> [list.repeat(Empty, list.length(tiles) + 2)]
    _ -> output
  }

  let output = [tiles, ..output]

  case rest {
    "" -> [list.repeat(Empty, list.length(tiles) + 2), ..output] |> list.reverse
    _ -> do_parse(rest, output, on_newline)
  }
}

fn find_free_rolls(rows: List(List(Tile))) -> List(#(Int, Int)) {
  rows
  |> list.window(3)
  |> list.index_map(fn(triple_row, y) {
    triple_row
    |> list.transpose
    |> list.window(3)
    |> list.index_map(fn(kernel, x) { #(list.flatten(kernel), y, x) })
  })
  |> list.flatten
  |> list.filter_map(fn(kernel_y_x) {
    let #(kernel, y, x) = kernel_y_x
    let rolls = list.count(kernel, fn(tile) { tile == Roll })
    case kernel {
      [_, _, _, _, Roll, _, _, _, _] if rolls < 5 -> Ok(#(y, x))
      _ -> Error(Nil)
    }
  })
}

fn remove_rolls(
  rows: List(List(Tile)),
  new_rows: List(List(Tile)),
  to_remove: List(#(Int, Int)),
  y: Int,
) -> List(List(Tile)) {
  case rows {
    [] -> new_rows |> list.reverse
    [row] -> remove_rolls([], [row, ..new_rows], to_remove, y + 1)
    [row, ..remaining_rows] if y == -1 ->
      remove_rolls(remaining_rows, [row, ..new_rows], to_remove, y + 1)
    [row, ..remaining_rows] -> {
      let #(new_row, to_remove) =
        list.index_fold(row, #([], to_remove), fn(acc, tile, x) {
          let x = x - 1
          case acc {
            #(new_row, to_remove) if x == -1 -> #([tile, ..new_row], to_remove)
            #(new_row, []) -> #([tile, ..new_row], [])
            #(new_row, [#(ry, rx), ..rest_to_remove]) -> {
              case bool.and(ry == y, rx == x) {
                False -> #([tile, ..new_row], [#(ry, rx), ..rest_to_remove])
                True -> #([Empty, ..new_row], rest_to_remove)
              }
            }
          }
        })
      remove_rolls(
        remaining_rows,
        [list.reverse(new_row), ..new_rows],
        to_remove,
        y + 1,
      )
    }
  }
}
