import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/string

type Pos {
  Pos(x: Int, y: Int)
}

type Pair {
  Pair(a: Pos, b: Pos, area: Int)
}

type Tile {
  RedOrGreen
  Other
}

type Bounds {
  Bounds(min_x: Int, min_y: Int, max_x: Int, max_y: Int)
}

type Floor =
  dict.Dict(Pos, Tile)

pub fn part_1(input: String) -> Int {
  let assert Ok(Pair(area:, ..)) =
    parse(input)
    |> list.combination_pairs
    |> list.map(tuple_pair_to_pair_area)
    |> list.sort(cmp_pair_by_area)
    |> list.reverse
    |> list.first
  area
}

pub fn part_2(input: String) -> Int {
  let red_tiles = parse(input)
  let assert [first_red_tile, ..rest_red_tiles] = red_tiles
  let floor: Floor =
    trace_red_or_green(
      list.append(rest_red_tiles, [first_red_tile]),
      dict.new(),
      first_red_tile,
    )

  let bounds: Bounds =
    get_bounds(
      red_tiles,
      Bounds(
        min_x: first_red_tile.x,
        min_y: first_red_tile.y,
        max_x: first_red_tile.x,
        max_y: first_red_tile.y,
      ),
    )

  let pairs =
    list.combination_pairs(red_tiles)
    |> list.map(tuple_pair_to_pair_area)
    |> list.sort(cmp_pair_by_area)
    |> list.reverse

  process(pairs, floor, bounds)
}

fn parse(input: String) -> List(Pos) {
  string.split(input, on: "\n")
  |> list.map(fn(line) {
    let assert [x, y] =
      string.split(line, on: ",")
      |> list.map(fn(nums) {
        let assert Ok(val) = int.parse(nums)
        val
      })
    Pos(x:, y:)
  })
}

fn tuple_pair_to_pair_area(tuple_pair: #(Pos, Pos)) -> Pair {
  let #(a, b) = tuple_pair
  Pair(
    a:,
    b:,
    area: { int.absolute_value({ a.x - b.x }) + 1 }
      * { int.absolute_value({ a.y - b.y }) + 1 },
  )
}

fn cmp_pair_by_area(a: Pair, b: Pair) -> order.Order {
  int.compare(a.area, b.area)
}

fn trace_red_or_green(
  red_tiles: List(Pos),
  floor: Floor,
  last_red_tile: Pos,
) -> Floor {
  case red_tiles {
    [] -> floor
    [Pos(x:, y:), ..red_tiles] if last_red_tile.x == x -> {
      trace_red_or_green(
        red_tiles,
        list.range(y, last_red_tile.y)
          |> list.fold(floor, fn(f, y) {
            dict.insert(f, Pos(x:, y:), RedOrGreen)
          }),
        Pos(x:, y:),
      )
    }
    [Pos(x:, y:), ..red_tiles] if last_red_tile.y == y -> {
      trace_red_or_green(
        red_tiles,
        list.range(x, last_red_tile.x)
          |> list.fold(floor, fn(f, x) {
            dict.insert(f, Pos(x:, y:), RedOrGreen)
          }),
        Pos(x:, y:),
      )
    }
    _ -> panic as { "Adjacent tiles are not orthogonally placed!" }
  }
}

fn get_bounds(red_tiles: List(Pos), bounds: Bounds) -> Bounds {
  case red_tiles {
    [] -> bounds
    [Pos(x:, y:), ..rest] ->
      get_bounds(
        rest,
        Bounds(
          min_x: int.min(x, bounds.min_x),
          min_y: int.min(y, bounds.min_y),
          max_x: int.max(x, bounds.max_x),
          max_y: int.max(y, bounds.max_y),
        ),
      )
  }
}

fn process(pairs: List(Pair), floor: Floor, bounds: Bounds) -> Int {
  case pairs {
    [] -> panic as "We didn't find anything..!?"
    [pair, ..rest] ->
      case check_pair(pair, floor, bounds) {
        #(option.Some(area), _floor) -> area
        #(option.None, floor) -> process(rest, floor, bounds)
      }
  }
}

fn check_pair(
  pair: Pair,
  floor: Floor,
  bounds: Bounds,
) -> #(option.Option(Int), Floor) {
  let Pair(a:, b:, area:) = pair
  let to_check =
    list.fold(list.range(a.x, b.x), [], fn(positions, x) {
      list.fold(list.range(a.y, b.y), positions, fn(positions, y) {
        [Pos(x:, y:), ..positions]
      })
    })
  case check_tiles(to_check, floor, bounds) {
    #(True, floor) -> #(option.Some(area), floor)
    #(False, floor) -> #(option.None, floor)
  }
}

fn check_tiles(
  to_check: List(Pos),
  floor: Floor,
  bounds: Bounds,
) -> #(Bool, Floor) {
  case to_check {
    [] -> #(True, floor)
    [tile, ..to_check] ->
      case flood_check_and_update(tile, [], floor, bounds) {
        #(True, floor) -> check_tiles(to_check, floor, bounds)
        #(False, floor) -> #(False, floor)
      }
  }
}

fn flood_check_and_update(
  tile: Pos,
  list: List(Pos),
  floor: Floor,
  bounds: Bounds,
) -> #(Bool, Floor) {
  case dict.get(floor, tile) {
    Ok(RedOrGreen) -> #(True, floor)
    Ok(Other) -> {
      let floor =
        list.fold([tile, ..list], floor, fn(floor, pos) {
          dict.upsert(floor, pos, fn(opt) {
            case opt {
              option.Some(t) -> t
              option.None -> Other
            }
          })
        })
      #(False, floor)
    }
    Error(_) -> {
      case
        bool.or(tile.x < bounds.min_x, tile.x > bounds.max_x)
        |> bool.or(tile.y < bounds.min_y)
        |> bool.or(tile.y > bounds.max_y)
      {
        True -> {
          flood_check_and_update(
            tile,
            list,
            dict.insert(floor, tile, Other),
            bounds,
          )
        }
        False -> {
          list.fold(
            [
              Pos(tile.x - 1, tile.y),
              Pos(tile.x + 1, tile.y),
              Pos(tile.x, tile.y - 1),
              Pos(tile.x, tile.y + 1),
            ],
            #(True, floor),
            fn(success_floor, pos) {
              let #(success, floor) = success_floor
              let #(new_success, floor) =
                flood_check_and_update(pos, [tile, ..list], floor, bounds)
              case bool.and(success, new_success) {
                False -> #(False, floor)
                True -> {
                  let floor =
                    list.fold([tile, ..list], floor, fn(floor, pos) {
                      dict.upsert(floor, pos, fn(opt) {
                        case opt {
                          option.Some(t) -> t
                          option.None -> RedOrGreen
                        }
                      })
                    })
                  #(True, floor)
                }
              }
            },
          )
        }
      }
    }
  }
}
