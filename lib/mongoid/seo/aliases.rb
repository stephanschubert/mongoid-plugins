require "active_support/concer"

module Mongoid
  module SEO
    module Aliases
      extend ActiveSupport::Concern

      module ClassMethods

        def aliases(*fields)
          fields.each do |name|
            field "#{name}_aliases".to_sym, type: Array, default: []
            before_save "update_#{name}_aliases".to_sym, :if => "#{name}_changed?".to_sym

            instance_eval <<-CODE
              def update_#{name}_aliases
                #{name}_aliases.push(#{name}_was)
              end
            CODE
          end
        end

      end
    end
  end
end
