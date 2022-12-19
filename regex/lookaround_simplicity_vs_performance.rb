# frozen_string_literal: true

# Tradeoffs:
# - Succinct.
# - Requires deeper regex knowledge.
# - No need to create a separate array of words, which means lower working
#   memory usage.
# - Better performance when one needs to know the last-matched alternation.
def matches_with_regex(string)
  regex = /(\b(?=\w{6,12}\b)\w{0,9}(cat|dog|mouse)\w*)/
  string.scan(regex)
end

# Tradeoffs:
# - Much more code than the Regex solution, but easier to understand and
#   maintain without requiring deep regex knowledge.
# - Slightly better CPU performance.
def matches_with_iteration(string)
  words_to_find_within = %w[cat dog mouse]
  string.enum_for(:split, ' ').with_object([]) do |word, matches|
    next unless word.size.between?(6, 12)

    previously_found_index = nil
    found_within = nil
    words_to_find_within.each do |word_to_find|
      index = word.index(word_to_find)
      next if index.nil? || (!previously_found_index.nil? && index < previously_found_index)

      previously_found_index = index
      found_within = word_to_find
    end
    next if found_within.nil?

    matches << [word, found_within]
  end
end

require_relative '../../ruby-common/benchmark_report'
require_relative '../../ruby-common/test'

TESTS = [
  { input: 'cat category dog dogged mouse mousey dogmouse mousedog',
    expected_output: [%w[category cat], %w[dogged dog], %w[mousey mouse], %w[dogmouse mouse],
                      %w[mousedog dog]] },
  { input: (%w[cat category dog dogged mouse mousey dogmouse mousedog] * 500).join(' '),
    expected_output: [%w[category cat], %w[dogged dog], %w[mousey mouse], %w[dogmouse mouse],
                      %w[mousedog dog]] * 500 }
].freeze

return unless run_tests('regex', TESTS, ->(input) { matches_with_regex(input) })
return unless run_tests('iteration', TESTS, ->(input) { matches_with_iteration(input) })

benchmark_report(TESTS,
                 [
                   { label: 'regex', method: ->(input) { matches_with_regex(input) } },
                   { label: 'iteration', method: ->(input) { matches_with_iteration(input) } }
                 ],
                 iterations: 1500)
