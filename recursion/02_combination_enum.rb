# frozen_string_literal: true

# Write a Ruby-flavored algorithm that generates an array of unique combinations
# of `n` elements within a given array, then implement.

# Implementation adapted from this source: https://www.geeksforgeeks.org/print-all-possible-combinations-of-r-elements-in-a-given-array-of-size-n/

# TODO: encapsulate combination selection
#   - Yield each combination as an array of indices
#   - Select the data at those indices as a group from input_array.
#   - Then, there's no need to pass input_array to `combinations_recurse`, and
#     the combination selection algorithm can be used with virtually any structure.

# rubocop:disable Metrics/ParameterLists
# Recursion adapted and simplified from [this source](https://www.baeldung.com/java-combinations-algorithm#:~:text=let's%20write%20the%20recursive%20method%20to%20implement%20this%20approach)
def combinations_recurse(input_array, c_size,
                         start_idx = 0, combo = [], combo_idx = 0, combos = [])
  end_idx = input_array.size - 1

  max = [end_idx, end_idx + 1 - combo.size + combo_idx].min
  (start_idx..max).each do |idx|
    combo[combo_idx] = input_array[idx]

    next (combos << combo.dup) if combo_idx == c_size - 1

    combinations_recurse(input_array, c_size,
                         idx + 1, combo, combo_idx + 1, combos)
  end

  combos
end
# rubocop:enable Metrics/ParameterLists

def combinations_all(input_array, c_size)
  return [[]] if c_size.zero?
  return [] if c_size.negative? || input_array.empty? || c_size > input_array.size

  combinations_recurse(input_array, c_size)
end

# - idx0: iterate through all until only c_size elements remain; i.e., 0..(arr.size - c_size).
#   - iterate through all indices after idx0 to identify idx1
#     - iterate through all indices after idx1 to identify idx2
#       - iterate through all indices after idx2 to identify idx3

# - Loop: 0..(arr.size - c_size) do |start_idx|
#   - Dig (recurse) until `c_size - 1` levels deep:
#     If c_size = 2, it will recurse once.
#     If c_size = 3, it will recurse twice, and so on.
#     - Once our combination array size == c_size, return the combination.
#     - Iterate through the remaining elements after the last combination's element

# - Iterate through possible 1st indices:
#   (0..arr_size - c_size) |start_idx|
#   - Iterate through possible 2nd indices:
#     ((start_idx + 1)..arr_size - c_size + 1) |idx_offset1|
#     - Iterate through possible 3rd indices:
#       ((idx_offset1 + 1)..arr_size - c_size + 2) |idx_offset2|
#       - Iterate through possible last indices:
#         ((idx_offset2 + 1)..[arr_size - c_size + 3, arr_size - 1].max) |idx_offset_last|
#         - yield combo[start_idx, idx_offset1, idx_offset2, idx_offset_last]
#
# Given arr = [0, 1, 2, 3, 4, 5] and c_size = 4
# - start_idx = 0
#     (1..3).each do |idx_offset1|
#       (2..4).each do |idx_offset2|
#         (3..5).each do |idx_offset_last|
#           - yield [0, 1, 2, 3]
#           - yield [0, 1, 2, 4]
#           - yield [0, 1, 2, 5]
#             - yield [0, 1, 3, 4]
#             - yield [0, 1, 3, 5]
#               - yield [0, 1, 4, 5]
#                 - yield [0, 2, 3, 4]
#                 - yield [0, 2, 3, 5]
#                   - yield [0, 2, 4, 5]
#                     - yield [0, 3, 4, 5]
# - start_idx = 1
#     (2..3).each do |idx_offset1|
#       (3..4).each do |idx_offset2|
#         (4..5).each do |idx_offset_last|
#           - yield [1, 2, 3, 4]
#           - yield [1, 2, 3, 5]
#             - yield [1, 2, 4, 5]
#               - yield [1, 3, 4, 5]
# - start_idx = 2
#     (3..3).each do |idx_offset1|
#       (4..4).each do |idx_offset2|
#         (5..5).each do |idx_offset_last|
#           - yield [2, 3, 4, 5]

class ArrayCustom
  def initialize(array)
    @array = array
  end

  def combination(c_size, yield_indices: false)
    combination_with_validation(c_size) do
      enum_for(:combination_each, c_size, yield_indices)
    end
  end

  # For better performance when loading all combinations into an array???
  def combination_all(c_size)
    combination_with_validation(c_size) do
      combination_all_recurse(c_size)
    end
  end

  private

  attr_reader :array

  def combination_with_validation(c_size)
    return [[]] if c_size.zero?
    return [] if c_size.negative? || array.empty? || c_size > array.size

    yield
  end

  def combination_each(c_size, yield_indices,
                       start_idx: 0, combo: [], level: 0,
                       &block)
    end_idx = array.size - c_size + level

    (start_idx..end_idx).each do |idx|
      combo[level] = yield_indices ? idx : array[idx]
      next yield combo.dup if level == c_size - 1

      combination_each(c_size, yield_indices,
                       start_idx: idx + 1, combo: combo, level: level + 1,
                       &block)
    end
  end

  def combination_all_recurse(c_size,
                              start_idx: 0, combo: [], level: 0,
                              combos: [])
    end_idx = array.size - c_size + level

    (start_idx..end_idx).each do |idx|
      combo[level] = array[idx]
      next combos << combo.dup if level == c_size - 1

      combination_all_recurse(c_size,
                              start_idx: idx + 1, combo: combo, level: level + 1,
                              combos: combos)
    end

    combos
  end
end

def combinations_via_enumeration(arr, c_size)
  ArrayCustom.new(arr).combination(c_size).to_a
end

def combinations_all2(arr, c_size)
  ArrayCustom.new(arr).combination_all(c_size)
end

def example_combination_enumeration(arr, c_size)
  puts '* Enumeration *'
  enum = ArrayCustom.new(arr).combination(c_size)
  loop do
    print 'Press enter for next combination...'
    gets
    p enum.next
  rescue StopIteration
    puts 'No more combinations.'
    break
  end
end

def example_combination_enumerate_all(arr, c_size)
  puts '* All combinations of indices *'
  ArrayCustom.new(arr).combination(c_size, yield_indices: false).each { |combo| p combo }
end

# example_combination_enumeration([12, 13, 7, 5, 10, 16], 4)
# example_combination_enumerate_all([12, 13, 7, 5, 10, 16], 4)
# return

# Standard Library:
def combination_std_lib(arr, c_size)
  arr.combination(c_size).to_a
end

require 'json'
# File.write('./combination52-5.json', JSON.dump(combinations_via_enumeration((1..52).to_a, 5).to_a))

require_relative '../../ruby-common/benchmark_report'
require_relative '../../ruby-common/test'

TESTS = [
  { input: [[], 1], expected_output: [] },
  { input: [[12], 0], expected_output: [[]] },
  { input: [[12, 2], 3], expected_output: [] },
  { input: [[12], -1], expected_output: [] },
  { input: [[12], 1], expected_output: [[12]] },
  { input: [[12, 13, 7, 5], 1], expected_output: [[12], [13], [7], [5]] },
  { input: [[12, 13, 7, 5], 2], expected_output: [[12, 13], [12, 7], [12, 5], [13, 7], [13, 5], [7, 5]] },
  { input: [[12, 13, 7, 5], 3], expected_output: [[12, 13, 7], [12, 13, 5], [12, 7, 5], [13, 7, 5]] },
  { input: [[12, 13, 7, 5, 10], 2],
    expected_output: [[12, 13], [12, 7], [12, 5], [12, 10], [13, 7], [13, 5], [13, 10], [7, 5], [7, 10], [5, 10]] },
  { input: [[12, 13, 7, 5, 10], 3],
    expected_output: [[12, 13, 7], [12, 13, 5], [12, 13, 10], [12, 7, 5], [12, 7, 10], [12, 5, 10], [13, 7, 5],
                      [13, 7, 10], [13, 5, 10], [7, 5, 10]] },
  { input: [[12, 13, 7, 5], 4], expected_output: [[12, 13, 7, 5]] },
  { input: [[12, 13, 7, 5, 10, 16], 4],
    expected_output: [[12, 13, 7, 5], [12, 13, 7, 10], [12, 13, 7, 16], [12, 13, 5, 10],
                      [12, 13, 5, 16], [12, 13, 10, 16], [12, 7, 5, 10], [12, 7, 5, 16],
                      [12, 7, 10, 16], [12, 5, 10, 16], [13, 7, 5, 10], [13, 7, 5, 16],
                      [13, 7, 10, 16], [13, 5, 10, 16], [7, 5, 10, 16]] },
  { input: [[12, 13, 7, 5, 10, 16, 21], 4],
    expected_output: [[12, 13, 7, 5], [12, 13, 7, 10], [12, 13, 7, 16], [12, 13, 7, 21],
                      [12, 13, 5, 10], [12, 13, 5, 16], [12, 13, 5, 21], [12, 13, 10, 16],
                      [12, 13, 10, 21], [12, 13, 16, 21], [12, 7, 5, 10], [12, 7, 5, 16],
                      [12, 7, 5, 21], [12, 7, 10, 16], [12, 7, 10, 21], [12, 7, 16, 21],
                      [12, 5, 10, 16], [12, 5, 10, 21], [12, 5, 16, 21], [12, 10, 16, 21],
                      [13, 7, 5, 10], [13, 7, 5, 16], [13, 7, 5, 21], [13, 7, 10, 16],
                      [13, 7, 10, 21], [13, 7, 16, 21], [13, 5, 10, 16], [13, 5, 10, 21],
                      [13, 5, 16, 21], [13, 10, 16, 21], [7, 5, 10, 16], [7, 5, 10, 21],
                      [7, 5, 16, 21], [7, 10, 16, 21], [5, 10, 16, 21]] },
  { input: [(1..52).to_a, 5],
    expected_output: JSON.parse(File.read('./combination52-5.json')) }
].freeze

run_tests('combinations_all', TESTS, ->(input) { combinations_all(*input) })
run_tests('combinations_via_enum', TESTS, ->(input) { combinations_via_enumeration(*input) })
run_tests('combinations_all2', TESTS, ->(input) { combinations_all2(*input) })
run_tests('combination_std_lib', TESTS, ->(input) { combination_std_lib(*input) })

benchmark_report(2, 3, TESTS,
                 [
                   { label: 'combinations_all', method: ->(input) { combinations_all(*input) } },
                   { label: 'combination_via_enum', method: ->(input) { combinations_via_enumeration(*input) } },
                   { label: 'combinations_all2', method: ->(input) { combinations_all2(*input) } },
                   { label: 'combination_std_lib', method: ->(input) { combination_std_lib(*input) } }
                 ])

# ** What I learned **
# - Not surprisingly, the Standard Library's **Array#combination** is much
#   faster than any custom implementation.
# - With larger sets, enumeration can be 50% slower.
#   - Ruby must optimize performance at the runtime layer (C) to avoid that
#     performance hit. As usual, use built-in Ruby functions when possible.

# *** Latest logical processing attempt ***
