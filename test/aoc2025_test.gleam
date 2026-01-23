import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
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
  assert day2.part_2(input) == 4_174_379_265
}

pub fn day3_test() {
  let input =
    "987654321111111
811111111111119
234234234234278
818181911112111"
  assert day3.part_1(input) == 357
  assert day3.part_2(input) == 3_121_910_778_619
}

pub fn day4_test() {
  let input =
    "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."
  assert day4.part_1(input) == 13
  assert day4.part_2(input) == 43
}

pub fn day5_test() {
  let input =
    "3-5
10-14
16-20
12-18

1
5
8
11
17
32"
  assert day5.part_1(input) == 3
  assert day5.part_2(input) == 14
}

pub fn day6_test() {
  let input = "./input/day6_example.txt"
  assert day6.part_1(input) == 4_277_556
  assert day6.part_2(input) == 3_263_827
}

pub fn day7_test() {
  let input =
    ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."
  assert day7.part_1(input) == 21
  assert day7.part_2(input) == 40
}

pub fn day8_test() {
  let input =
    "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689"
  assert day8.part_1(input, "10") == 40
  assert day8.part_2(input) == 25_272
}
