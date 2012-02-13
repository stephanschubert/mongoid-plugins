require "active_support/concern"

module Mongoid
  module Variants
    extend ActiveSupport::Concern

    included do
      field :variants, type: Array, default: []
    end

    # These attributes shouldn't be compared because
    # they're internal ones and differ anyway.
    INTERNAL_ATTRIBUTES = %w(
      _id        # Mongoid's document id
      created_at # Mongoid::Timestamps
      updated_at # Mongoid::Timestamps
      variants   # That's us!
    )

    # Returns all attributes which differ from +other+
    def variant_attributes(other, options = {})
      blocked_attributes = INTERNAL_ATTRIBUTES + options[:block].to_a

      a =  self.attributes.block(*blocked_attributes)
      b = other.attributes.block(*blocked_attributes)

      a.inject({}) do |memo, (k,v)|
        memo[k] = v unless b[k] == v
        memo
      end
    end
  end
end
