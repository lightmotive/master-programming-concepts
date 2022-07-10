# frozen_string_literal: true

# require 'pry'
# Sum the digits of a number
# - Convert the number to a string.
# - Sum each character converted to a number.

num = 123
# p num.to_s.chars.map(&:to_i).sum

def sum_digits(num)
  chars = num.to_s.chars

  return chars.first.to_i if chars.size == 1

  sum_digits(chars.first) + sum_digits(chars[1..].join)
end

p sum_digits(num)
