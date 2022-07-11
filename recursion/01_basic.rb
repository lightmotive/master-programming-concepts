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

# Another problem:
# - Get the absolute sum of the differences between two arrays of integers of
# the same length.

# Input: Two arrays of integers that are the same length
# Output: The sum of the absolute difference between the index-correlated
#         numbers in 2 arrays.

# Rules
# - Each array contains only integers.
# - Each array is the same length.

# Examples/Tests
# sum_absolute_differences([1], [2, 3]) => ArgumentError
# sum_absolute_differences([3, 7], [19, 12]) == 21
# sum_absolute_differences(15,-4,56,10,-23], [14,-9,56,14,-23]) == 10

# Data Structure
# - Iterate through each index of the first array.

# Algorithm

# Code
