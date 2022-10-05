# frozen_string_literal: true

# Generate and track usage of unique names matching /\A[A-Z]{1,}\d{1,}\z/.
#
# Public behaviors:
# - `::new(letter_count=2, number_count=3)`: specify the number of letters and
#   numbers that form the name.
# - `#use!`: shift a name from a pre-shuffled list of available names, then
#   block that name from further use until released.
# - `#release!(name)`: append the name to list of available names; returns `self`.
#
# Possible name permutations example:
# - A pattern of 2 upper-case letters comprises 676 permutations (26^2).
# - A pattern of 3 digits comprises 1,000 permutations (10^3).
# - The product of those two permutation sets comprises all possible names this
#   class can generate: 676 * 1000 = 676,000.
class UniqueNames
  attr_reader :letter_count, :number_count

  def initialize(letter_count = 2, number_count = 3)
    @letter_count = letter_count
    @number_count = number_count
    initialize_names!
  end

  def use!
    raise StandardError, 'No names available' if names.empty?

    names.shift
  end

  def release!(name)
    names << name
    self
  end

  def [](*args)
    names.[](*args)
  end

  def to_a
    names.dup
  end

  # Enumerator for all possible names as arrays of letter-digit arrays:
  # [[l, l], [d, d, d]].
  def sequences
    letter_digit_sequences(letter_count, number_count)
  end

  private

  attr_reader :names

  def initialize_names!
    name_possibilities = letter_digit_sequences(letter_count, number_count)
    @names = name_possibilities.map do |letters, digits|
      letters.join + digits.join
    end
    @names.shuffle!
  end

  def letter_digit_sequences(letter_count, digit_count)
    letter_permutations = char_permutations('A'..'Z', letter_count)
    digit_permutations = char_permutations(0..9, digit_count)
    letter_permutations.enum_for(:product, digit_permutations) do
      letter_permutations.size * digit_permutations.size
    end
  end

  def char_permutations(char_range, length)
    char_range.to_a.repeated_permutation(length).to_a.uniq
  end
end
