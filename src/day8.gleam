import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/string

type Pos {
  Pos(x: Int, y: Int, z: Int)
}

type Pair {
  Pair(a: Pos, b: Pos, distance: Float)
}

type Seen =
  dict.Dict(Pos, Int)

type Circuits =
  dict.Dict(Int, List(Pos))

pub fn part_1(input: String, joins_arg: String) -> Int {
  let assert Ok(joins) = int.parse(joins_arg)
  let #(circuits, _last_pair) =
    parse(input)
    |> list.combination_pairs
    |> list.map(pos_tuple_to_pair_distance)
    |> list.sort(cmp_pair_dist)
    |> list.take(joins)
    |> process(dict.new(), dict.new(), 0, Pair(Pos(0, 0, 0), Pos(0, 0, 0), 0.0))
  count_circuits_and_product_top_3(circuits)
}

pub fn part_2(input: String) -> Int {
  let #(_circuits, Pair(a: Pos(x: ax, ..), b: Pos(x: bx, ..), ..)) =
    parse(input)
    |> list.combination_pairs
    |> list.map(pos_tuple_to_pair_distance)
    |> list.sort(cmp_pair_dist)
    |> process(dict.new(), dict.new(), 0, Pair(Pos(0, 0, 0), Pos(0, 0, 0), 0.0))
  ax * bx
}

fn parse(input: String) -> List(Pos) {
  string.split(input, on: "\n")
  |> list.map(fn(line) {
    let assert [x, y, z] =
      string.split(line, on: ",")
      |> list.map(fn(nums) {
        let assert Ok(val) = int.parse(nums)
        val
      })
    Pos(x:, y:, z:)
  })
}

fn pos_tuple_to_pair_distance(pair: #(Pos, Pos)) -> Pair {
  let #(a, b) = pair
  let dx = a.x - b.x
  let dy = a.y - b.y
  let dz = a.z - b.z
  let assert Ok(distance) =
    int.square_root({ dx * dx } + { dy * dy } + { dz * dz })
  Pair(a:, b:, distance:)
}

fn cmp_pair_dist(a: Pair, b: Pair) -> order.Order {
  float.compare(a.distance, b.distance)
}

fn process(
  pairs: List(Pair),
  circuits: Circuits,
  seen: Seen,
  next_circuit_id: Int,
  last_pair: Pair,
) -> #(Circuits, Pair) {
  case pairs {
    [] -> #(circuits, last_pair)
    [Pair(a:, b:, distance:), ..pairs] ->
      case dict.get(seen, a), dict.get(seen, b) {
        Ok(circuit_a_id), Ok(circuit_b_id) if circuit_a_id == circuit_b_id ->
          process(pairs, circuits, seen, next_circuit_id, last_pair)
        Ok(circuit_a_id), Ok(circuit_b_id) -> {
          let #(circuits, seen) =
            combine_circuits(
              circuit_a_id,
              circuit_b_id,
              circuits,
              seen,
              next_circuit_id,
            )
          process(
            pairs,
            circuits,
            seen,
            next_circuit_id + 1,
            Pair(a:, b:, distance:),
          )
        }
        Ok(circuit_a_id), Error(_) -> {
          let #(circuits, seen) = add_circuit(circuits, seen, circuit_a_id, b)
          process(
            pairs,
            circuits,
            seen,
            next_circuit_id,
            Pair(a:, b:, distance:),
          )
        }
        Error(_), Ok(circuit_b_id) -> {
          let #(circuits, seen) = add_circuit(circuits, seen, circuit_b_id, a)
          process(
            pairs,
            circuits,
            seen,
            next_circuit_id,
            Pair(a:, b:, distance:),
          )
        }
        Error(_), Error(_) -> {
          let #(circuits, seen) =
            new_circuit(circuits, seen, a, b, next_circuit_id)
          process(
            pairs,
            circuits,
            seen,
            next_circuit_id + 1,
            Pair(a:, b:, distance:),
          )
        }
      }
  }
}

fn count_circuits_and_product_top_3(circuits: Circuits) -> Int {
  list.map(dict.values(circuits), list.length)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, fn(acc, x) { acc * x })
}

fn new_circuit(
  circuits: Circuits,
  seen: Seen,
  a: Pos,
  b: Pos,
  next_circuit_id: Int,
) -> #(Circuits, Seen) {
  #(
    dict.insert(circuits, next_circuit_id, [a, b]),
    dict.insert(seen, a, next_circuit_id) |> dict.insert(b, next_circuit_id),
  )
}

fn add_circuit(
  circuits: Circuits,
  seen: Seen,
  circuit_id: Int,
  pos: Pos,
) -> #(Circuits, Seen) {
  #(
    dict.upsert(circuits, circuit_id, fn(value) {
      case value {
        option.Some(list) -> [pos, ..list]
        option.None -> [pos]
      }
    }),
    dict.insert(seen, pos, circuit_id),
  )
}

fn combine_circuits(
  circuit_a_id: Int,
  circuit_b_id: Int,
  circuits: Circuits,
  seen: Seen,
  next_circuit_id: Int,
) -> #(Circuits, Seen) {
  let assert Ok(circuit_a) = dict.get(circuits, circuit_a_id)
  let assert Ok(circuit_b) = dict.get(circuits, circuit_b_id)
  let circuit_c = list.append(circuit_a, circuit_b)
  #(
    dict.delete(circuits, circuit_a_id)
      |> dict.delete(circuit_b_id)
      |> dict.insert(next_circuit_id, circuit_c),
    list.fold(circuit_c, seen, fn(seen, pos) {
      dict.insert(seen, pos, next_circuit_id)
    }),
  )
}
