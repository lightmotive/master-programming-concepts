# frozen_string_literal: true

# require 'pry'
# Sum the digits of a number
# - Convert the number to a string.
# - Sum each character converted to a number.

num = 123
# p num.to_s.chars.map(&:to_i).sum

def sum_digits(num)
  string = num.to_s
  # That line works whether `num` is an Integer or a String because
  # **String#to_s** returns `self`.
  return string.to_i if string.length == 1

  chars = string.chars
  sum_digits(chars.first) + sum_digits(chars[1..].join)
end

p sum_digits(num)
