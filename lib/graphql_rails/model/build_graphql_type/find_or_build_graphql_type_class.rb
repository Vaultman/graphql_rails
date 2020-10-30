# frozen_string_literal: true

module GraphqlRails
  module Model
    class BuildGraphqlType
      # Initializes class to define graphql type and fields.
      class FindOrBuildGraphqlTypeClass
        require 'graphql_rails/concerns/service'

        include ::GraphqlRails::Service

        def initialize(name:, description:)
          @name = name
          @description = description
          @new_class = false
        end

        def klass
          @klass ||= begin
            type_name = name
            type_description = description
            klass_name = "#{type_name}Type"

            if Object.const_defined?(klass_name)
              self.new_class = false
              return Object.const_get(klass_name)
            end

            klass = Class.new(GraphQL::Schema::Object) do
              graphql_name(type_name)
              description(type_description)
            end

            self.new_class = true

            Object.const_set(klass_name, klass)
          end
        end

        def new_class?
          klass && new_class
        end

        protected

        attr_accessor :new_class

        private

        attr_reader :name, :description
      end
    end
  end
end
