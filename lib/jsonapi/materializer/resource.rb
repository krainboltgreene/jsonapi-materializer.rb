module JSONAPI
  module Materializer
    module Resource
      require_relative("resource/relationship")

      extend(ActiveSupport::Concern)

      included do
        include(ActiveModel::Model)

        unless const_defined?("Collection")
          self::Collection = Class.new do
            include(JSONAPI::Materializer::Collection)
          end
        end

        @attributes = {}
        @relations = {}

        origin(JSONAPI::Materializer.configuration.default_origin)
        identifier(JSONAPI::Materializer.configuration.default_identifier)

        has(:id)

        attr_accessor(:object)
        attr_writer(:selects)
        attr_writer(:includes)
      end

      def as_data
        {
          :id => id.to_s,
          :type => type.to_s,
          :attributes => attributes.
            select {|_, value| value.selectable}.
            slice(*selects).
            transform_values {|attribute| object.public_send(attribute.from)},
          :relationships => relations.
            transform_values {|relation| relation.using(self).as_json},
          :links => {
            :self => links_self
          }
        }.transform_values(&:presence).compact
      end

      def as_json(*)
        {
          :links => {
            :self => links_self
          },
          :data => as_data,
          :included => included
        }.transform_values(&:presence).compact
      end

      private def id
        object.public_send(identifier).to_s
      end

      def type
        self.class.instance_variable_get(:@type).to_s
      end

      private def attributes
        self.class.instance_variable_get(:@attributes)
      end

      def attribute(name)
        attributes.fetch(name.to_sym).for(object)
      end

      private def relations
        self.class.instance_variable_get(:@relations)
      end

      def relation(name)
        relations.fetch(name.to_sym).for(object)
      end

      def links_self
        Addressable::Template.new(
          "#{origin}/#{type}/#{object.public_send(identifier)}"
        ).pattern
      end

      private def origin
        self.class.instance_variable_get(:@origin)
      end

      private def identifier
        self.class.instance_variable_get(:@identifier)
      end

      private def selects
        @selects || attributes.select {|_, value| value.selectable}.keys
      end

      private def includes
        @includes || []
      end

      private def included
        includes.flat_map do |path|
          path.reduce(materializer) do |subject, key|
            if subject.is_a?(Array)
              subject.map {|related_subjet| related_subjet.relation(key)}
            else
              subject.relation(key)
            end
          end
        end.uniq.map(&:as_data)
        includes.flat_map do |path|
          path.reduce(self) do |subject, key|
            if subject.is_a?(Array)
              subject.map {|related_subjet| related_subjet.relation(key)}
            else
              subject.relation(key)
            end
          end
        end.map(&:as_data)
      end

      class_methods do
        def identifier(value)
          @identifier = value
        end

        def origin(value)
          @origin = value
        end

        def type(value)
          @type = value
        end

        def has(name, from: name, selectable: false)
          @attributes[name] = Attribute.new(:name => name, :from => from, :selectable => selectable)
        end

        def has_one(name, from: name, class_name:, includable: false)
          @relations[name] = Relation.new(:type => :one, :name => name, :from => from, :class_name => class_name, :includable => includable)
        end

        def has_many(name, from: name, class_name:, includable: false)
          @relations[name] = Relation.new(:type => :many, :name => name, :from => from, :class_name => class_name, :includable => includable)
        end
      end
    end
  end
end
