# frozen_string_literal: true

# A list optimized for fast seeking.
# - Uses binary search internally, so the list is always sorted.
#
# Key public behaviors:
# - `add(item)`:
# - `add_batch(item_array)`: list maintenance will run after concatenating all
#   items.
# - `batch_maintenance_completed!`: invoke after modifying items that would
#   change the sort order.
class FastList
  include Enumerable

  def initialize
    @items = []
  end

  def each(&block)
    items.each(&block)
  end

  def find(name)
    items.bsearch { |r| name <=> r.name }
  end

  def add(item)
    insert_before_idx = items.bsearch_index { |r| r.name > item.name } ||
                        items.size
    items.insert(insert_before_idx, item)
    item
  end

  def delete(item)
    delete_at_idx = items.bsearch_index { |r| r.name <=> item.name }
    return nil if delete_at_idx.nil?

    items.delete_at(delete_at_idx)
  end

  def add_batch(item_array)
    items.concat(item_array)
    batch_maintenance_completed!
  end

  def batch_maintenance_completed!
    items.sort_by!(&:name)
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
