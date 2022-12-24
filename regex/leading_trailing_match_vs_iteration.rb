# frozen_string_literal: true

# Outcome:
# - When matching simple leading/trailing values, iteration is over 3x faster!
# Analysis:
# - When it's possible to match a portion of a string--in this case, we only
#   need to look at leading and trailing separators--iteration should be faster
#   because it can look at a portion of a string instead of checking every
#   character.
# - There may be a faster regexes that what I wrote below; I'll explore this
#   again when I learn something relevant.

PATH_SEPARATOR = '/'
class PathNormalizerRegex
  attr_reader :paths_normalized

  def initialize(paths)
    @paths_normalized = compact(normalize(paths.flatten))
  end

  def joined
    squeeze_separators(paths_normalized.join(PATH_SEPARATOR))
  end

  private

  # - Retain single leading separators for first path, if any.
  # - Remove leading and trailing separators from middle paths.
  # - Retain single trailing slash for last path, if any.
  def normalize(paths)
    paths = compact(paths)
    return [''] if paths.empty?

    paths[0] = normalize_first_path(paths[0])
    return paths if paths.size == 1

    paths[-1] = normalize_last_path(paths[-1])
    return paths if paths.size == 2

    paths[1..-2] = normalize_middle_paths(paths[1..-2])

    paths
  end

  # - Remove nil and empty elements.
  # - Consolidate sequential separators in each path into one.
  def compact(paths)
    paths.compact.reject(&:empty?).map(&method(:squeeze_separators))
  end

  # Squeeze sequential separators, e.g., '//example///' => '/example/'
  def squeeze_separators(path)
    path.squeeze(PATH_SEPARATOR)
  end

  def trim_leading_separators(path)
    path.match(/(?:\A#{PATH_SEPARATOR}*)(.*)/)[1]
  end

  def trim_trailing_separators(path)
    match = path.match(/.*(?=#{PATH_SEPARATOR}+\z)/)
    return path if match.nil?

    match[0]
  end

  # Retain up to 1 leading separator and remove trailing separators
  def normalize_first_path(path)
    match = path.match(/\A(#{PATH_SEPARATOR})?\1*(.*)/)
    return '' if match.nil?

    path = "#{match[1]}#{match[2]}"
    return path if path == PATH_SEPARATOR

    trim_trailing_separators(path)
  end

  # Remove leading and trailing separators
  def normalize_middle_paths(paths)
    paths.map do |path|
      path = trim_leading_separators(path)
      trim_trailing_separators(path)
    end
  end

  def normalize_last_path(path)
    trim_leading_separators(path)
  end
end

class PathNormalizerIteration
  attr_reader :paths_normalized

  def initialize(paths)
    @paths_normalized = compact(normalize(paths.flatten))
  end

  def joined
    squeeze_separators(paths_normalized.join(PATH_SEPARATOR))
  end

  private

  # - Retain single leading separators for first path, if any.
  # - Remove leading and trailing separators from middle paths.
  # - Retain single trailing slash for last path, if any.
  def normalize(paths)
    paths = compact(paths)
    return [''] if paths.empty?

    paths[0] = normalize_first_path(paths[0])
    return paths if paths.size == 1

    paths[-1] = normalize_last_path(paths[-1])
    return paths if paths.size == 2

    paths[1..-2] = normalize_middle_paths(paths[1..-2])

    paths
  end

  # - Remove nil and empty elements.
  # - Consolidate sequential separators in each path into one.
  def compact(paths)
    paths.compact.reject(&:empty?).map(&method(:squeeze_separators))
  end

  # Squeeze sequential separators, e.g., '//example///' => '/example/'
  def squeeze_separators(path)
    path.squeeze(PATH_SEPARATOR)
  end

  def trim_leading_separators(path)
    path = path[1..] while path.start_with?(PATH_SEPARATOR)
    path
  end

  def trim_trailing_separators(path)
    return path if path.length < 2

    path = path[0..-2] while path.end_with?(PATH_SEPARATOR)
    path
  end

  # Retain up to 1 leading separator and remove trailing separators
  def normalize_first_path(path)
    return path if path == PATH_SEPARATOR

    trim_trailing_separators(path)
  end

  # Remove leading and trailing separators
  def normalize_middle_paths(paths)
    paths.map do |path|
      path = trim_leading_separators(path)
      trim_trailing_separators(path)
    end
  end

  def normalize_last_path(path)
    trim_leading_separators(path)
  end
end

require_relative '../../ruby-common/benchmark_report'
require_relative '../../ruby-common/test'

TESTS = [
  { input: [''], expected_output: [] },
  { input: [nil], expected_output: [] },
  { input: ['start'], expected_output: ['start'] },
  { input: ['/'], expected_output: ['/'] },
  { input: ['/start'], expected_output: ['/start'] },
  { input: ['//start'], expected_output: ['/start'] },
  { input: %w[start 2], expected_output: %w[start 2] },
  { input: %w[start 2 3], expected_output: %w[start 2 3] },
  { input: ['/start', '2', '3'], expected_output: ['/start', '2', '3'] },
  { input: ['/start', '/2', '/3'], expected_output: ['/start', '2', '3'] },
  { input: ['start/', '2/', '3/'], expected_output: ['start', '2', '3/'] },
  { input: ['start/', '/2/', '/3/'], expected_output: ['start', '2', '3/'] },
  { input: ['start/', '/2/', '/3//'], expected_output: ['start', '2', '3/'] },
  { input: ['start', '', ''], expected_output: ['start'] },
  { input: ['/start', '', ''], expected_output: ['/start'] },
  { input: ['/start/', '', ''], expected_output: ['/start'] },
  { input: ['/'], expected_output: ['/'] },
  { input: ['/', '/'], expected_output: ['/'] },
  { input: ['/', '//'], expected_output: ['/'] },
  { input: ['/', '/2', '/3/', '4', '/5', '6'], expected_output: ['/', '2', '3', '4', '5', '6'] },
  { input: ['/', '/2', '/3/', '4/'], expected_output: ['/', '2', '3', '4/'] }
].freeze

return unless run_tests('regex', TESTS, ->(input) { PathNormalizerRegex.new(input).paths_normalized })
return unless run_tests('iteration', TESTS, ->(input) { PathNormalizerIteration.new(input).paths_normalized })

benchmark_report(TESTS,
                 [
                   { label: 'regex', method: ->(input) { PathNormalizerRegex.new(input).paths_normalized } },
                   { label: 'iteration', method: ->(input) { PathNormalizerIteration.new(input).paths_normalized } }
                 ],
                 iterations: 1500)
