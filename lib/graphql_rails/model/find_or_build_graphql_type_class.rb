# frozen_string_literal: true

module GraphqlRails
  module Model
    # Initializes class to define graphql type and fields.
    class FindOrBuildGraphqlTypeClass
      require 'graphql_rails/concerns/service'

      include ::GraphqlRails::Service

      def initialize(name:, type_name:, description: nil)
        @name = name
        @type_name = type_name
        @description = description
      end

      def klass
        @klass ||= begin
          if Object.const_defined?(type_name)
            self.new_class = false
            return Object.const_get(type_name)
          end

          build_graphql_type_klass
        end
      end

      def new_class?
        new_class
      end

      private

      attr_accessor :new_class
      attr_reader :name, :type_name, :description
      attr_writer :klass

      def build_graphql_type_klass
        graphql_type_name = name
        graphql_type_description = description

        self.klass = Class.new(GraphQL::Schema::Object) do
          graphql_name(graphql_type_name)
          description(graphql_type_description)
        end

        self.new_class = true

        Object.const_set(type_name, klass)
      end
    end
  end
end
