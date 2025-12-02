import gleam/int
import gleam/list
import splitter

type Move {
  L(Int)
  R(Int)
}

pub fn part_1(input: String) -> Int {
  parse_1(input)
  |> compute_1(50)
}

fn parse_1(input: String) -> List(Move) {
  let newline_splitter = splitter.new(["\n", "\r\n"])
  do_parse_1(input, [], newline_splitter)
}

fn do_parse_1(
  input: String,
  output: List(Move),
  splitter: splitter.Splitter,
) -> List(Move) {
  let #(move, rest) = case splitter.split(splitter, input) {
    #("L" <> digits, _, rest) -> {
      let assert Ok(distance) = int.parse(digits)
      #(L(distance), rest)
    }

    #("R" <> digits, _, rest) -> {
      let assert Ok(distance) = int.parse(digits)
      #(R(distance), rest)
    }

    #(line, _, _) -> panic as { "Unexpected line: '" <> line <> "'" }
  }

  let output = [move, ..output]

  case rest {
    "" -> list.reverse(output)

    _ -> do_parse_1(rest, output, splitter)
  }
}

fn compute_1(moves: List(Move), start: Int) -> Int {
  moves
  |> list.scan(start, fn(pos, move) {
    case move {
      L(n) -> pos - n
      R(n) -> pos + n
    }
  })
  |> list.count(fn(pos) { pos % 100 == 0 })
}

pub fn part_2(input: String) -> Int {
  let #(precount, moves) = parse_2(input)
  compute_2(moves, 50, precount)
}

fn parse_2(input: String) -> #(Int, List(Move)) {
  let newline_splitter = splitter.new(["\n", "\r\n"])
  do_parse_2(input, #(0, []), newline_splitter)
}

fn do_parse_2(
  input: String,
  output: #(Int, List(Move)),
  splitter: splitter.Splitter,
) -> #(Int, List(Move)) {
  let #(direction, digits, rest) = case splitter.split(splitter, input) {
    #("L" <> digits, _, rest) -> #(L, digits, rest)
    #("R" <> digits, _, rest) -> #(R, digits, rest)
    #(line, _, _) -> panic as { "Unexpected line: '" <> line <> "'" }
  }

  let assert Ok(distance) = int.parse(digits)
  let rem = distance % 100
  let #(count, moves) = output
  let moves = [direction(rem), ..moves]
  let count = count + { distance / 100 }

  case rest {
    "" -> #(count, list.reverse(moves))

    _ -> do_parse_2(rest, #(count, moves), splitter)
  }
}

fn compute_2(moves: List(Move), pos: Int, count: Int) -> Int {
  case pos, moves {
    _, [] -> count
    0, [L(n), ..rest] -> compute_2(rest, 100 - n, count)
    _, [L(n), ..rest] if pos - n < 1 ->
      compute_2(rest, { 100 - n + pos } % 100, count + 1)
    _, [L(n), ..rest] -> compute_2(rest, pos - n, count)
    0, [R(n), ..rest] -> compute_2(rest, n, count)
    _, [R(n), ..rest] if pos + n > 99 ->
      compute_2(rest, { pos + n } % 100, count + 1)
    _, [R(n), ..rest] -> compute_2(rest, pos + n, count)
  }
}
