require "active_support/concern"

module Mongoid
  module Variants
    extend ActiveSupport::Concern

    included do
      # Save all variants as an array of hashes containing
      # the key/value pairs which differ from the document's attributes
      field :variants, type: Array, default: []

      # Find document with a variant matching the given +options+
      # +options+ will get automatically scoped to "variants."
      #
      # So calling
      #   Model.with_variant(bacon: true, amount: 5)
      #
      # will result in a query like this:
      #   Model.where("variants.bacon": true, "variants.amount": 5)
      #
      scope :with_variant, ->(options) {
        scoped_options = options.inject({}) do |memo, (k,v)|
          memo["variants.#{k}"] = v
          memo
        end
        where(scoped_options)
      }
    end

    # These attributes shouldn't be compared because
    # they're internal ones and differ anyway.
    INTERNAL_ATTRIBUTES = %w(
      _id        # Mongoid's document id
      created_at # Mongoid::Timestamps
      updated_at # Mongoid::Timestamps
      variants   # That's us!
    )

    # Returns all attributes which differ from the +other+ document ones.
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
