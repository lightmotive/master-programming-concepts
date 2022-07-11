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

p sum_digits(num) == 6

# Another problem:
# - Get the absolute sum of the differences between two arrays of integers of
# the same length.

# Input: Two arrays of integers that are the same length
# Output: The sum of the absolute difference between the index-correlated
#         numbers in 2 arrays.

# Rules
# - Each array is the same length.
# - Each array contains only integers.

# Examples/Tests
# sum_abs_diff([1], [2, 3]) => ArgumentError
# sum_abs_diff([1, 2], ['2', 3]) => ArgumentError
# sum_abs_diff([3, 7], [19, 12]) == 21
# sum_abs_diff([15,-4,56,10,-23], [14,-9,56,14,-23]) == 10

# Data Structure
# - Iterate through each index of the first array.

# Algorithm
# - Raise exception if arrays are not of the same length (separate method).
# - Raise exception if arrays contain anything other than integers.
# - Find sum_abs_diff between arr1 and arr2:
#   sum = 0
#   Iterate from (0...first array's length) |idx|
#     sum += abs(arr1[idx] - arr2[idx])
#
#   sum

# Code

def all_integers?(arr)
  arr.all? { |e| e.instance_of?(Integer) }
end

def sum_abs_diff(arr1, arr2)
  raise ArgumentError, 'The array sizes must match.' if arr1.size != arr2.size
  unless all_integers?(arr1) && all_integers?(arr2)
    raise ArgumentError, 'The arrays must contain only Integer elements.'
  end

  sum_abs_diff_iterate(arr1, arr2)
end

def sum_abs_diff_iterate(arr1, arr2)
  sum = 0

  (0...arr1.size).each do |idx|
    sum += (arr1[idx] - arr2[idx]).abs
  end

  sum
end

begin
  sum_abs_diff([1], [2, 3])
  p false
rescue ArgumentError
  p true
end

begin
  sum_abs_diff([1, 2], ['2', 3])
  p false
rescue ArgumentError
  p true
end

p sum_abs_diff([3, 7], [19, 12]) == 21
p sum_abs_diff([15, -4, 56, 10, -23], [14, -9, 56, 14, -23]) == 10
