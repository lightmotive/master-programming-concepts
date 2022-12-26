# frozen_string_literal: true

# Goal: check whether a string is a pangram (contains every letter of the
#       alphabet at least once).
# Outcome: downcasing the string, then `('a'..'z').all? { |x| string.include?(x) }`
#          is significantly faster than all other solutions, including regex,
#          dictionary, set, and array subtraction. It's also easy to read and
#          understand.
# Analysis: use Ruby's built-in methods whenever possible to maximize
#           performance.

require 'set'

def pangram_delete?(string)
  string.downcase.delete('^a-z').chars.uniq.size == 26
end

def pangram_scan?(string)
  string.downcase.scan(/[a-z]/).uniq.size == 26
end

def pangram_ss?(string)
  letters = ('a'..'z').to_a

  string.downcase.chars.each do |char|
    delete_letter_idx = letters.bsearch_index { |letter| char <=> letter }
    letters.delete_at(delete_letter_idx) unless delete_letter_idx.nil?
    # Short-circuit
    return true if letters.size.zero?
  end

  false
end

def pangram_all?(string)
  string = string.downcase
  ('a'..'z').all? { |x| string.include?(x) }
end

def pangram_dictionary?(string)
  dict = Set.new(%w[a b c d e f g h i j k l m n o p q r s t u v w x y z])
  string.downcase.each_char do |c|
    dict.delete(c) if dict.include?(c)
    return true if dict.empty?
  end
  dict.empty?
end

def pangram_dictionary2?(string)
  hash = ('a'..'z').each_with_object({}) { |k, obj| obj[k] = 0 }
  string.downcase.chars.each do |c|
    hash[c] = hash[c] + 1 if hash.keys.include? c
  end

  hash.select { |_k, v| v == 0 }.empty?
end

def panagram_array_subtraction?(string)
  ([*'a'..'z'] - string.downcase.chars).empty?
end

def pangram_set?(string)
  lets = Set.new(%w[a b c d e f g h i j k l m n o p q r s t
                    u v w x y z])
  string.downcase.each_char { |ch| lets.delete(ch) if lets.include?(ch) }
  lets.empty?
end

require_relative 'ruby-common/benchmark_report'
require_relative 'ruby-common/test'

TESTS = [
  { input: 'The quick brown fox jumps over the lazy dog.', expected_output: true },
  { input: 'This is not a pangram.', expected_output: false },
  { input: "#{('a'..'z').to_a.join}The quick brown fox jumps over the lazy dog.", expected_output: true }
].freeze

run_tests('delete', TESTS, ->(input) { pangram_delete?(input) })
run_tests('pangram_dictionary2', TESTS, ->(input) { pangram_dictionary2?(input) })
run_tests('dictionary', TESTS, ->(input) { pangram_dictionary?(input) })
run_tests('panagram_array_subtraction', TESTS, ->(input) { panagram_array_subtraction?(input) })
run_tests('all?', TESTS, ->(input) { pangram_all?(input) })
run_tests('set?', TESTS, ->(input) { pangram_set?(input) })

benchmark_report(TESTS,
                 [
                   { label: 'delete', method: ->(input) { pangram_delete?(input) } },
                   { label: 'pangram_dictionary2', method: ->(input) { pangram_dictionary2?(input) } },
                   { label: 'panagram_array_subtraction', method: ->(input) { panagram_array_subtraction?(input) } },
                   { label: 'dictionary', method: ->(input) { pangram_dictionary?(input) } },
                   { label: 'set', method: ->(input) { pangram_set?(input) } },
                   { label: 'all?', method: ->(input) { pangram_all?(input) } }
                 ])

# ** Simple test **

def option1(input)
  input.sort! { |first, second| second <=> first }
end

def option2(input)
  input.sort!.reverse!
end

TESTS = [
  { input: ['Charlie and the Chocolate Factory', 'War and Peace',
            'Utopia', 'A Brief History of Time',
            'A Wrinkle in Time'],
    expected_output: ['War and Peace', 'Utopia',
                      'Charlie and the Chocolate Factory',
                      'A Wrinkle in Time', 'A Brief History of Time'] }
].freeze

run_tests('option1', TESTS, ->(input) { option1(input) })
run_tests('option2', TESTS, ->(input) { option2(input) })

benchmark_report(TESTS,
                 [
                   { label: 'option1', method: ->(input) { option1(input) } },
                   { label: 'option2', method: ->(input) { option2(input) } }
                 ])
