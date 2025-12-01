import gleam/int
import gleam/list
import splitter

type Direction {
  Left
  Right
}

type Instruction {
  Instruction(direction: Direction, distance: Int)
}

pub fn part_1(input: String) -> Int {
  parse_1(input)
  |> compute_1(50, 0)
}

pub fn part_2(input: String) -> Int {
  parse_1(input)
  |> compute_2(50, 0)
}

fn parse_1(input: String) -> List(Instruction) {
  let newline_splitter = splitter.new(["\n", "\r\n"])

  do_parse(input, [], newline_splitter)
}

fn do_parse(
  input: String,
  output: List(Instruction),
  splitter: splitter.Splitter,
) -> List(Instruction) {
  let #(direction, digits, rest) = case splitter.split(splitter, input) {
    #("L" <> digits, _, rest) -> #(Left, digits, rest)

    #("R" <> digits, _, rest) -> #(Right, digits, rest)

    #(line, _, _) -> panic as { "Unexpected line: '" <> line <> "'" }
  }

  let assert Ok(distance) = int.parse(digits)
  let output = [Instruction(direction:, distance:), ..output]

  case rest {
    "" -> list.reverse(output)

    _ -> do_parse(rest, output, splitter)
  }
}

fn compute_1(instructions: List(Instruction), location: Int, count: Int) -> Int {
  case instructions {
    [] -> count

    [Instruction(direction:, distance:), ..rest] -> {
      let delta = case direction {
        Left -> -distance

        Right -> distance
      }
      let assert Ok(location) = int.modulo(location + delta, by: 100)
      case location {
        0 -> compute_1(rest, location, count + 1)

        _ -> compute_1(rest, location, count)
      }
    }
  }
}

fn compute_2(instructions: List(Instruction), location: Int, count: Int) -> Int {
  case instructions {
    [] -> count

    [Instruction(direction: _, distance: 0), ..rest] ->
      compute_2(rest, location, count)

    [Instruction(direction:, distance:), ..rest] -> {
      let location = case direction {
        Left -> location - 1
        Right -> location + 1
      }

      case int.modulo(location, 100) {
        Ok(0) ->
          compute_2(
            [Instruction(direction:, distance: distance - 1), ..rest],
            location,
            count + 1,
          )
        Ok(_) ->
          compute_2(
            [Instruction(direction:, distance: distance - 1), ..rest],
            location,
            count,
          )
        Error(_) -> panic
      }
    }
  }
}
