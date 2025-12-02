import day1
import day2
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn day1_test() {
  let input =
    "L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"
  assert day1.part_1(input) == 3
  assert day1.part_2(input) == 6
}

pub fn day2_test() {
  let input =
    "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"
  assert day2.part_1(input) == 1_227_775_554
  assert day2.part_2(input) == 4174379265
}
