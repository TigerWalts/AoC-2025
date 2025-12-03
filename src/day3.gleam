import gleam/int
import gleam/list
import gleam/string
import splitter

pub fn part_1(input: String) -> Int {
  parse_1(input)
  |> compute_1(0)
}

fn parse_1(input: String) -> List(List(Int)) {
  let on_newline = splitter.new(["\n", "\r\n"])
  do_parse_1(input, [], on_newline)
}

fn do_parse_1(
  input: String,
  output: List(List(Int)),
  on_newline: splitter.Splitter,
) -> List(List(Int)) {
  let #(row, _, rest) = splitter.split(on_newline, input)
  let assert Ok(nums) = string.to_graphemes(row) |> list.try_map(int.parse)
  let output = [nums, ..output]

  case rest {
    "" -> list.reverse(output)
    _ -> do_parse_1(rest, output, on_newline)
  }
}

fn compute_1(rows: List(List(Int)), total: Int) -> Int {
  case rows {
    [] -> total
    [row, ..rest] -> {
      let max_not_at_end =
        row
        |> list.reverse
        |> list.drop(1)
        |> list.fold(1, int.max)

      let next_max =
        row
        |> list.drop_while(fn(num) { num != max_not_at_end })
        |> list.drop(1)
        |> list.fold(1, int.max)

      compute_1(rest, total + { max_not_at_end * 10 } + next_max)
    }
  }
}
