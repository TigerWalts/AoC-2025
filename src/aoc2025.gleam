import argv
import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import gleam/int
import gleam/io
import simplifile

pub fn main() -> Nil {
  case argv.load().arguments {
    ["day1", "part1", filepath] -> get_file_content(filepath) |> day1.part_1
    ["day1", "part2", filepath] -> get_file_content(filepath) |> day1.part_2
    ["day2", "part1", filepath] -> get_file_content(filepath) |> day2.part_1
    ["day2", "part2", filepath] -> get_file_content(filepath) |> day2.part_2
    ["day3", "part1", filepath] -> get_file_content(filepath) |> day3.part_1
    ["day3", "part2", filepath] -> get_file_content(filepath) |> day3.part_2
    ["day4", "part1", filepath] -> get_file_content(filepath) |> day4.part_1
    ["day4", "part2", filepath] -> get_file_content(filepath) |> day4.part_2
    ["day5", "part1", filepath] -> get_file_content(filepath) |> day5.part_1
    ["day5", "part2", filepath] -> get_file_content(filepath) |> day5.part_2
    ["day6", "part1", filepath] -> day6.part_1(filepath)
    ["day6", "part2", filepath] -> day6.part_2(filepath)
    ["day7", "part1", filepath] -> get_file_content(filepath) |> day7.part_1
    ["day7", "part2", filepath] -> get_file_content(filepath) |> day7.part_2
    ["day8", "part1", filepath, joins] ->
      get_file_content(filepath) |> day8.part_1(joins)
    ["day8", "part2", filepath] -> get_file_content(filepath) |> day8.part_2
    _ -> panic as "Unknown commands"
  }
  |> int.to_string
  |> io.println
}

fn get_file_content(filepath: String) -> String {
  let assert Ok(content) = simplifile.read(from: filepath)
  content
}
