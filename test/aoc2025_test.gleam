import day1
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn day1_test() {
  assert day1.part_1(
      "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82",
    )
    == 3
}
