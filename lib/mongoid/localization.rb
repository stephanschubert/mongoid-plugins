require "active_support/concern"

module Mongoid
  module Localization
    extend ActiveSupport::Concern
    extend Forwardable

    included do
      cattr_accessor \
      :localized_fields,
      :localized_languages,
      :localization_class

      self.localization_class = Mongoid::Localization::Localization

      embeds_many :localizations,
      class_name: localization_class.name,
      as: :localizable

      accepts_nested_attributes_for :localizations

      before_create :setup_empty_localizations
    end

    def_delegators "self.class",
    :localized_fields,
    :localized_languages

    def setup_empty_localizations
      localized_languages.each do |lang|
        localizations.new(language: lang)
      end
    end

    module ClassMethods # ----------------------------------

      def localize(*fields)
        options = fields.extract_options!
        fields  = [fields].flatten

        self.localized_fields    = fields
        self.localized_languages = [options[:for]].flatten

        self.localization_class.class_eval do
          fields.each do |name|
            field name
          end
        end
      end

    end

    class Localization # -----------------------------------
      include Mongoid::Document
      embedded_in :localizable, polymorphic: true, inverse_of: :localizations

      field :language
      # TODO validate

      def localized_fields
        localizable.class.localized_fields
      end
    end

  end
end
