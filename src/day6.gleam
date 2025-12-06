import file_streams/file_stream.{type FileStream}
import gleam/int
import gleam/list
import gleam/string

type Op {
  Add
  Mul
}

pub fn part_1(filename: String) -> Int {
  let assert Ok(filestream) = file_stream.open_read(filename)
  let operations = prescan_1(filestream)
  let assert Ok(0) =
    file_stream.position(filestream, file_stream.BeginningOfFile(0))
  let #(operations, starting) =
    list.map(operations, fn(operation) {
      case operation {
        Add -> #(int.add, 0)
        Mul -> #(int.multiply, 1)
      }
    })
    |> list.unzip
  apply_operations(filestream, operations, starting)
  |> list.fold(0, int.add)
}

pub fn part_2(filename: String) -> Int {
  let assert Ok(filestream) = file_stream.open_read(filename)
  let assert [ops_line, ..data_lines] = prescan_2(filestream, [])
  let operations =
    string.split(ops_line, " ")
    |> list.filter(keeping: fn(chunk) { chunk != "" })
  let #(data_sets, _) =
    list.map(data_lines, string.to_graphemes)
    |> list.transpose
    |> list.fold(#([], []), with: fn(acc, chars) {
      let #(output, data_set) = acc
      case string.concat(chars) |> string.trim {
        "" -> #([data_set, ..output], [])
        str -> {
          let assert Ok(value) = int.parse(str)
          #(output, [value, ..data_set])
        }
      }
    })
  list.reverse(data_sets)
  |> list.zip(operations)
  |> list.map(fn(dataset_op) {
    case dataset_op {
      #(data, "+") -> list.fold(data, 0, int.add)
      #(data, "*") -> list.fold(data, 1, int.multiply)
      #(_, op) -> panic as { "Unsupported op" <> op }
    }
  })
  |> list.fold(0, int.add)
}

fn prescan_1(filestream: FileStream) -> List(Op) {
  let assert Ok(line) = file_stream.read_line(filestream)
  case string.ends_with(line, "\n") {
    True -> prescan_1(filestream)
    False -> {
      string.split(line, " ")
      |> list.filter_map(fn(part) {
        case part {
          "" -> Error(Nil)
          "*" -> Ok(Mul)
          "+" -> Ok(Add)
          _ -> panic as { "Unexpected operator: " <> part }
        }
      })
    }
  }
}

fn prescan_2(filestream: FileStream, acc: List(String)) -> List(String) {
  let assert Ok(line) = file_stream.read_line(filestream)
  case string.ends_with(line, "\n") {
    False -> [line, ..list.reverse(acc)]
    True -> prescan_2(filestream, [line, ..acc])
  }
}

fn apply_operations(
  filestream: FileStream,
  operations: List(fn(Int, Int) -> Int),
  onto: List(Int),
) -> List(Int) {
  let assert Ok(line) = file_stream.read_line(filestream)
  case string.ends_with(line, "\n") {
    False -> onto
    True -> {
      string.trim_end(line)
      |> string.split(" ")
      |> list.filter_map(fn(part) {
        case part {
          "" | "\n" -> Error(Nil)
          digits ->
            case int.parse(digits) {
              Ok(value) -> Ok(value)
              Error(_) -> panic as "failed to parse number"
            }
        }
      })
      |> list.zip(onto, _)
      |> list.zip(operations)
      |> list.map(fn(a_b_op) {
        let #(#(a, b), op) = a_b_op
        op(a, b)
      })
      |> apply_operations(filestream, operations, _)
    }
  }
}
