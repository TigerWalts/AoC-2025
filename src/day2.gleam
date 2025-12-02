import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import splitter

pub type Range {
  Range(start: Int, stop: Int, next: Int)
}

fn new_range(start: Int, stop: Int) -> Range {
  case start > stop {
    False -> Range(start:, stop:, next: start)
    True -> panic as "Invalid Range"
  }
}

fn range_next(range: Range) -> #(Int, Option(Range)) {
  let Range(start:, stop:, next:) = range

  case next == stop {
    False -> #(next, Some(Range(start:, stop:, next: next + 1)))
    True -> #(next, None)
  }
}

pub fn part_1(input: String) -> Int {
  parse_1(input)
  |> compute_1(None, 0, is_invalid_1)
}

fn parse_1(input: String) -> List(Range) {
  let at_comma = splitter.new([","])
  let at_dash = splitter.new(["-"])
  do_parse_1(input, [], at_comma, at_dash)
}

fn do_parse_1(
  input: String,
  output: List(Range),
  at_comma: splitter.Splitter,
  at_dash: splitter.Splitter,
) -> List(Range) {
  let #(range, _, rest) = splitter.split(at_comma, input)
  let #(start, _, stop) = splitter.split(at_dash, range)

  let assert Ok(start) = int.parse(start)
  let assert Ok(stop) = int.parse(stop)

  let output = [new_range(start, stop), ..output]

  case rest {
    "" -> list.reverse(output)
    _ -> do_parse_1(rest, output, at_comma, at_dash)
  }
}

fn compute_1(
  ranges: List(Range),
  current_range: Option(Range),
  total: Int,
  is_invalid: fn(Int) -> Bool,
) -> Int {
  case ranges, current_range {
    [], None -> total
    [range, ..rest], None -> compute_1(rest, Some(range), total, is_invalid)
    _, Some(range) -> {
      let #(id, range) = range_next(range)
      case is_invalid(id) {
        False -> compute_1(ranges, range, total,is_invalid)
        True -> compute_1(ranges, range, total + id, is_invalid)
      }
    }
  }
}

fn is_invalid_1(id: Int) -> Bool {
  let digits = int.to_string(id)
  let length = string.length(digits)
  case length % 2 == 0 {
    False -> False
    True -> {
      let #(left, right) =
        digits
        |> string.to_graphemes
        |> list.split(length / 2)

      left == right
    }
  }
}

pub fn part_2(input: String) -> Int {
  parse_1(input)
  |> compute_1(None, 0, is_invalid_2)
}

fn is_invalid_2(id: Int) -> Bool {
  let digits = int.to_string(id)
  let length = string.length(digits)
  case length {
    1 -> False
    2 -> id % 11 == 0
    3 -> id % 111 == 0
    4 -> bool.or(id % 1111 == 0, id / 100 == id % 100) 
    5 -> id % 11111 == 0
    _ -> {
      let digits = string.to_graphemes(digits)
      
      list.range(1, length - 1)
      |> list.any(fn (span) {
        case length % span {
          0 -> {
            {list.sized_chunk(digits, span) |> list.unique |> list.length} == 1
          }
          _ -> False
        }
      })
    }
  }
}
