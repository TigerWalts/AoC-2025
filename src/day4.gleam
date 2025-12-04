import gleam/list
import gleam/string
import splitter

type Tile {
  Empty
  Roll
}

pub fn part_1(input) -> Int {
  parse(input)
  |> compute_1
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

fn compute_1(rows: List(List(Tile))) -> Int {
  rows
  |> list.window(3)
  |> list.map(fn(triple_row) {
    triple_row
    |> list.map(fn(row) {
      row
      |> list.window(3)
    })
    |> list.transpose
  })
  |> list.flatten
  |> list.count(fn(kernel) {
    let tiles =
      kernel
      |> list.flatten
    let rolls = list.count(tiles, fn(tile) { tile == Roll })
    case rolls, tiles {
      rolls, [_, _, _, _, Roll, _, _, _, _] if rolls < 5 -> True
      _, _ -> False
    }
  })
}
