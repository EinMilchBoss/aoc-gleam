import gleam/dict
import gleam/int
import gleam/list
import gleam/set
import gleam/string

import year_2024/day_05/rules.{type Rules}

pub type Manual =
  List(Int)

pub fn parse(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(",")
    |> list.map(fn(string) {
      let assert Ok(int) = string |> int.parse() as "pages are always ints"

      int
    })
  })
}

pub fn get_middle_page(manual: Manual) -> Int {
  let half = list.length(manual) / 2
  let #(_, right) = list.split(manual, half)
  let assert Ok(middle) = list.first(right)
    as "every manual has at least one element"

  middle
}

pub fn manual_correct(manual: Manual, rules: Rules) -> Manual {
  do_manual_correct(manual, rules, [])
}

fn do_manual_correct(pages: List(Int), rules: Rules, acc: List(Int)) {
  case pages {
    [] -> acc
    [current, ..rest] -> {
      let wrong_pages =
        list.filter(rest, fn(next) { !is_page_valid(current, next, rules) })

      case wrong_pages {
        // No rule violation so the order can be kept.
        [] -> do_manual_correct(rest, rules, [current, ..acc])
        // At least one rule violation so we have to get the correct order
        // of the wrong pages and add those before our current page.
        _ -> {
          // Get the correct order of the wrong pages.
          let wrong_pages_corrected = do_manual_correct(wrong_pages, rules, [])

          // Remove them from further execution
          let filtered_rest =
            list.filter(rest, fn(page) { !list.contains(wrong_pages, page) })

          // Keep in mind the order is backwards. The first page is the last one
          // and the last one is the first, so we have to prepend everything.
          do_manual_correct(filtered_rest, rules, [
            current,
            ..list.append(wrong_pages_corrected, acc)
          ])
        }
      }
    }
  }
}

pub fn manual_is_correct(manual: Manual, rules: Rules) -> Bool {
  do_manual_is_correct(manual, rules)
}

fn do_manual_is_correct(pages: List(Int), rules: Rules) -> Bool {
  case pages {
    [] -> True
    [current, ..rest] -> {
      case list.any(rest, fn(next) { !is_page_valid(current, next, rules) }) {
        // One page is wrong so the entire manual is wrong.
        True -> False
        False -> do_manual_is_correct(rest, rules)
      }
    }
  }
}

pub fn is_page_valid(current: Int, next: Int, rules: Rules) -> Bool {
  case dict.get(rules, next) {
    // If there are no entries, then no rules could have been broken.
    Error(_) -> True
    // If a page after the current one has a rule which dictates
    // that the current page should come after, then it's invalid.
    Ok(pages_after_next) -> {
      !set.contains(pages_after_next, current)
    }
  }
}
