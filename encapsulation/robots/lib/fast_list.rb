# frozen_string_literal: true

# A list optimized for fast seeking.
# - Items must define `<=>` for sorting purposes.
# - Uses binary search internally, so the list will always be sorted.
#
# Key public behaviors:
# - `#add(item)`:
# - `#add_count(count) { |idx| item_to_add }`: add a number of items
#   sequentially. Improves performance over sequential `#add` invocations.
# - `#mutate_one(item) { |item| ... }`: mutate one item in a way that would
#   change its sort position. Item is removed from the list, yielded, and then
#   added back to the list in sorted position.
# - `#batch_mutate { ... }`: give block that mutates multiple stored objects in
#   a way that would change sort order. List is sorted after block returns.
class FastList
  def initialize
    @items = []
  end

  def find(item_to_find = nil, &block)
    return items.bsearch(&block) if block_given?
    return nil if item_to_find.nil?

    items.bsearch { |item| item_to_find <=> item }
  end

  def add(item_to_add)
    insert_before_idx = items.bsearch_index { |item| item > item_to_add } ||
                        items.size
    items.insert(insert_before_idx, item_to_add)
    item_to_add
  end

  def delete(item_to_delete)
    delete_at_idx = items.bsearch_index { |item| item_to_delete <=> item }
    return nil if delete_at_idx.nil?

    items.delete_at(delete_at_idx)
  end

  def mutate_one(item)
    raise StandardError, 'Block required' unless block_given?

    delete(item)
    begin
      yield(item)
    rescue StandardError => e
      raise e
    ensure
      add(item)
    end
  end

  def add_count(count)
    count.times do |idx|
      items << yield(idx)
    end
    batch_completed!
  end

  def batch_mutate
    yield
    batch_completed!
  end

  def size
    items.size
  end

  alias length size

  def [](*args)
    items.[](*args)
  end

  def to_a
    items.dup
  end

  private

  attr_reader :items

  def batch_completed!
    items.sort!
  end
end
