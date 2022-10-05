# frozen_string_literal: true

# A list optimized for fast seeking.
# - Items must define `<=>` for sorting purposes.
# - Uses binary search internally, so the list is always sorted.
#
# Key public behaviors:
# - `add(item)`:
# - `add_batch(item_array)`: list maintenance will run after concatenating all
#   items.
# - `batch_maintenance_completed!`: invoke after modifying items that would
#   change the sort order.
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

  def add_batch(item_array)
    items.concat(item_array)
    batch_maintenance_completed!
  end

  def batch_maintenance_completed!
    items.sort!
  end

  def [](*args)
    items.[](*args)
  end

  def to_a
    items.dup
  end

  private

  attr_reader :items
end
