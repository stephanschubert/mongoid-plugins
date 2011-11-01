require "active_support/concern"

module Mongoid
  module SEO
    extend ActiveSupport::Concern

    SEO_FIELDS = [
      :page_title,
      :meta_description
    ]

    included do
      SEO_FIELDS.each do |name|
        field name
      end
    end

    module ClassMethods # --------------------------------

      def seo_fields
        SEO_FIELDS
      end

    end

  end
end
