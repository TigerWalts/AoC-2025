import gleam/bool
import gleam/int
import gleam/list
import splitter.{type Splitter}

type ParseStage {
  Ranges
  IDs
}

type Range {
  Range(start: Int, stop: Int)
}

pub fn part_1(input: String) -> Int {
  let #(ranges, ids) = parse(input)
  collapse_ranges(ranges)
  |> count_ids_in_ranges(ids, _)
}

pub fn part_2(input: String) -> Int {
  let #(ranges, _) = parse(input)
  collapse_ranges(ranges)
  |> list.fold(0, fn(acc, range) { 1 + acc + range.stop - range.start })
}

fn parse(input: String) -> #(List(Range), List(Int)) {
  let on_newline = splitter.new(["\n", "\r\n"])
  let on_dash = splitter.new(["-"])
  do_parse(input, #([], []), Ranges, on_newline, on_dash)
}

fn do_parse(
  input: String,
  into: #(List(Range), List(Int)),
  stage: ParseStage,
  on_newline: Splitter,
  on_dash: Splitter,
) -> #(List(Range), List(Int)) {
  let #(line, _, rest) = splitter.split(on_newline, input)
  case stage, splitter.split(on_dash, line), into {
    IDs, #("", _, _), _ -> into
    IDs, #(_, "-", _), _ -> panic as "Expected an ID but it looks like a Range"
    IDs, #(id, _, _), #(ranges, ids) -> {
      let assert Ok(id) = int.parse(id)
      do_parse(rest, #(ranges, [id, ..ids]), stage, on_newline, on_dash)
    }
    Ranges, #("", _, _), _ -> do_parse(rest, into, IDs, on_newline, on_dash)
    Ranges, #(start, "-", stop), #(ranges, ids) -> {
      let assert Ok(start) = int.parse(start)
      let assert Ok(stop) = int.parse(stop)
      do_parse(
        rest,
        #([Range(start:, stop:), ..ranges], ids),
        stage,
        on_newline,
        on_dash,
      )
    }
    Ranges, _, _ -> panic as { "Unexpected line for parsing ranges: " <> line }
  }
}

fn collapse_ranges(ranges: List(Range)) -> List(Range) {
  list.sort(ranges, by: fn(a, b) { int.compare(a.start, b.start) })
  |> do_collapse_ranges([])
}

fn do_collapse_ranges(ranges: List(Range), into: List(Range)) -> List(Range) {
  case ranges {
    [] -> list.reverse(into)
    [just_one] -> do_collapse_ranges([], [just_one, ..into])
    [a, b, ..rest] if b.start <= a.stop ->
      do_collapse_ranges(
        [Range(a.start, int.max(a.stop, b.stop)), ..rest],
        into,
      )
    [range, ..rest] -> do_collapse_ranges(rest, [range, ..into])
  }
}

fn count_ids_in_ranges(ids: List(Int), ranges: List(Range)) -> Int {
  list.count(ids, fn(id) { id_in_ranges(id, ranges) })
}

fn id_in_ranges(id: Int, ranges: List(Range)) -> Bool {
  list.any(ranges, fn(range) { bool.and(id >= range.start, id <= range.stop) })
}
