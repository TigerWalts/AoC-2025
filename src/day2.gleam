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
  |> compute_1(None, 0)
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
) -> Int {
  case ranges, current_range {
    [], None -> total
    [range, ..rest], None -> compute_1(rest, Some(range), total)
    _, Some(range) -> {
      let #(id, range) = range_next(range)
      case is_invalid_1(id) {
        False -> compute_1(ranges, range, total)
        True -> compute_1(ranges, range, total + id)
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
