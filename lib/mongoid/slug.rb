require "active_support/concern"

module Mongoid
  module Slug
    extend ActiveSupport::Concern

    included do
      cattr_accessor :slugged_fields, :slug_name, :slug_builder
    end

    module ClassMethods # ----------------------------------

      def slug(*fields, &block)
        options = fields.extract_options!

        self.slug_name      = options[:as] || :slug
        self.slugged_fields = fields.map(&:to_s)
        self.slug_builder   = block_given? ? block : default_slug_builder

        # Setup slugged field
        field slug_name, type: String

        # Setup an index on the slugged field
        if options[:index]
          index slug_name
        end

        # Generate slug on every save or keep the first one?
        if options[:permanent]
          before_create :generate_slug
        else
          before_save :generate_slug
        end

        instance_eval <<-CODE
          def self.find_by_#{slug_name}(slug)
            where(slug_name => slug).first
          end

          def self.find_by_#{slug_name}!(slug)
            find_by_slug(slug) or
              raise Mongoid::Errors::DocumentNotFound.new(self.class, slug)
          end
        CODE
      end

      private # --------------------------------------------

      def default_slug_builder
        lambda do |doc|
          slugged_fields.map { |f| doc.read_attribute(f) }.join(" ").to_url
        end
      end

    end

    private # ----------------------------------------------

    def generate_slug
      write_attribute slug_name, find_unique_slug
    end

    def find_unique_slug
      slug    = slug_builder.call(self)
      pattern = /^#{Regexp.escape(slug)}(-\d+)?$/

      existing_slugs_count =
        self.class.
        only(slug_name).
        where(slug_name => pattern, :_id.ne => _id).
        count

      if existing_slugs_count > 0
        slug << "-#{existing_slugs_count}"
      end

      slug
    end

  end
end
