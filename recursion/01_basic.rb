# frozen_string_literal: true

# Sum the digits of a number
# - Convert the number to a string.
# - Sum each character converted to a number.

num = 123
p num.to_s.chars.map(&:to_i).sum
