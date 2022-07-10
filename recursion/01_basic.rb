# frozen_string_literal: true

# Sum the digits of a number
# - Convert the number to a string.
# - Sum each character converted to a number.

num = 123
# p num.to_s.chars.map(&:to_i).sum

def sum_digits(num)
  chars = num.to_s.chars
  sum = 0

  chars.each do |char|
    sum += char.to_i
  end

  sum
end

p sum_digits(num)
