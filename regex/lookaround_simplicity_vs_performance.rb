# frozen_string_literal: true

# Tradeoffs:
# - Succinct
# - Requires deeper regex knowledge
def match_using_regex(string)
  regex = /(\b(?=\w{6,12}\b)\w{0,9}(cat|dog|mouse)\w*)/
  string.scan(regex)
end

# Tradeoffs:
# - Easy to understand without deep regex knowledge.
# - Greater memory usage, especially with large strings (can offset that with line enumeration).
def match_using_iteration(string)
  regex = /\w*(cat|dog|mouse)\w*/
  string.split.each_with_object([]) do |word, matches|
    next unless word.size.between?(6, 12)

    capture_group = regex.match(word)[1]
    matches << [word, capture_group] if capture_group
  end
end

# Surprisingly, CPU performance is not a significant tradeoff in either case,
# even with longer strings. However, a system with slower memory performance
# might make a difference.

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

run_tests('regex', TESTS, ->(input) { match_using_regex(input) })
run_tests('iteration', TESTS, ->(input) { match_using_iteration(input) })

benchmark_report(TESTS,
                 [
                   { label: 'regex', method: ->(input) { match_using_regex(input) } },
                   { label: 'iteration', method: ->(input) { match_using_iteration(input) } }
                 ],
                 iterations: 1500)
