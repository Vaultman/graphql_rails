# frozen_string_literal: true

module GraphqlRails
  module Model
    # stores information about model specific config, like attributes and types
    class FindOrBuildGraphqlType
      require 'graphql_rails/concerns/service'
      require 'graphql_rails/model/build_graphql_type'
      require 'graphql_rails/model/build_graphql_type/find_or_build_graphql_type_class'

      include ::GraphqlRails::Service

      def initialize(name:, description: nil, attributes:)
        @name = name
        @attributes = attributes
        @description = description
      end

      def scalar_attributes
        @scalar_attributes ||= attributes.values.select(&:scalar_type?)
      end

      def dynamic_attributes
        @dynamic_attributes ||= attributes.values.reject(&:scalar_type?)
      end

      def call
        if type_class_finder.new_class?
          build_graphql_type(scalar_attributes)
          build_dynamic_fields do |name, description, attributes|
            FindOrBuildGraphqlType.call(name: name, description: description, attributes: attributes)
          end
          build_graphql_type(dynamic_attributes)
        end
        klass
      end

      def klass
        @klass ||= type_class_finder.klass
      end

      private

      def type_class_finder
        @type_class_finder ||= BuildGraphqlType::FindOrBuildGraphqlTypeClass.new(
          name: name,
          description: description
        )
      end

      attr_reader :attributes, :name, :description

      def build_dynamic_fields
        dynamic_attributes.each do |attribute|
          graphql_config = attribute.send(:type_parser).graphql_model.graphql
          yield(graphql_config.name, graphql_config.description, graphql_config.attributes)
        end
      end

      def build_graphql_type(model_attributes)
        BuildGraphqlType.call(klass: klass, attributes: model_attributes)
      end
    end
  end
end
