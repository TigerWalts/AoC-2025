import gleam/int
import gleam/list
import gleam/string
import splitter.{type Splitter}

pub fn part_1(input: String) -> Int {
  parse(input)
  |> compute(2, 0)
}

pub fn part_2(input: String) -> Int {
  parse(input)
  |> compute(12, 0)
}

fn parse(input: String) -> List(List(Int)) {
  let on_newline = splitter.new(["\n", "\r\n"])
  do_parse(input, [], on_newline)
}

fn do_parse(
  input: String,
  output: List(List(Int)),
  on_newline: Splitter,
) -> List(List(Int)) {
  let #(row, _, rest) = splitter.split(on_newline, input)
  let assert Ok(nums) = string.to_graphemes(row) |> list.try_map(int.parse)
  let output = [nums, ..output]

  case rest {
    "" -> list.reverse(output)
    _ -> do_parse(rest, output, on_newline)
  }
}

fn compute(rows: List(List(Int)), on: Int, total: Int) -> Int {
  case rows {
    [] -> total
    [row, ..rest] -> {
      let #(value, _) =
        list.range(on, 1)
        |> list.fold(#(0, row), fn(acc, left) {
          case acc, left {
            #(_, []), _ -> panic as "Exhausted the row. This shouldn't happen!"
            #(value, [num]), 1 -> #(value + num, [])
            #(value, nums), 1 -> #(value + list.fold(nums, 1, int.max), [])
            #(value, nums), _ -> {
              let biggest =
                nums
                |> list.reverse
                |> list.drop(left - 1)
                |> list.fold(1, int.max)

              let remaining =
                nums
                |> list.drop_while(fn(num) { num != biggest })
                |> list.drop(1)

              #({ value + biggest } * 10, remaining)
            }
          }
        })

      compute(rest, on, total + value)
    }
  }
}
