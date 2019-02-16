module JSONAPI
  module Materializer
    module Resource
      require_relative("resource/attribute")
      require_relative("resource/relation")
      require_relative("resource/relationship")
      require_relative("resource/configuration")

      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)

      MIXIN_HOOK = ->(*) do
        @attributes = {}
        @relations = {}

        unless const_defined?("Collection")
          self::Collection = Class.new do
            include(JSONAPI::Materializer::Collection)
          end
        end

        validates_presence_of(:object, allow_blank: true)

        origin(JSONAPI::Materializer.configuration.default_origin)
        identifier(JSONAPI::Materializer.configuration.default_identifier)

        has(JSONAPI::Materializer.configuration.default_identifier)
      end

      attr_accessor(:object)
      attr_writer(:selects)
      attr_writer(:includes)
      attr_reader(:raw)

      def initialize(**keyword_arguments)
        super(**keyword_arguments)

        @raw = keyword_arguments

        validate!
      end

      def as_data
        {
          :id => id,
          :type => type,
          :attributes => exposed(attributes.except(:id)).
            transform_values {|attribute| object.public_send(attribute.from)},
          :relationships => exposed(relations).
            transform_values {|relation| relation.using(self).as_json},
          :links => {
            :self => links_self
          }
        }.transform_values(&:presence).compact
      end

      private def exposed(mapping)
        if selects.any?
          mapping.slice(*selects.dig(type))
        else
          mapping
        end
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
        self.class.configuration.type.to_s
      end

      private def attributes
        self.class.configuration.attributes
      end

      private def origin
        self.class.configuration.origin
      end

      private def identifier
        self.class.configuration.identifier
      end

      private def relations
        self.class.configuration.relations
      end

      def attribute(name)
        self.class.attribute(name)
      end

      def relation(name)
        self.class.relation(name)
      end

      def links_self
        Addressable::Template.new(
          "#{origin}/#{type}/#{object.public_send(identifier)}"
        ).pattern
      end

      def selects
        (@selects || {}).transform_values {|list| list.map(&:to_sym)}
      end

      def includes
        @includes || []
      end

      private def included
        @included ||= includes.flat_map do |path|
          path.reduce(self) do |subject, key|
            if subject.is_a?(Array)
              subject.map {|related_subject| related_subject.relation(key).for(subject)}
            else
              subject.relation(key).for(subject)
            end
          end
        end.map(&:as_data)
      end

      included do
        class_eval(&MIXIN_HOOK) unless @abstract_class
      end

      class_methods do
        def inherited(object)
          object.class_eval(&MIXIN_HOOK) unless object.instance_variable_defined?(:@abstract_class)
        end

        def identifier(value)
          @identifier = value.to_sym
        end

        def origin(value)
          @origin = value
        end

        def type(value)
          @type = value.to_sym
        end

        def has(name, from: name)
          @attributes[name] = Attribute.new(
            :owner => self,
            :name => name,
            :from => from
          )
        end

        def has_one(name, from: name, class_name:)
          @relations[name] = Relation.new(
            :owner => self,
            :type => :one,
            :name => name,
            :from => from,
            :class_name => class_name
          )
        end

        def has_many(name, from: name, class_name:)
          @relations[name] = Relation.new(
            :owner => self,
            :type => :many,
            :name => name,
            :from => from,
            :class_name => class_name
          )
        end

        def configuration
          @configuration ||= Configuration.new(
            :owner => self,
            :type => @type,
            :origin => @origin,
            :identifier => @identifier,
            :attributes => @attributes,
            :relations => @relations
          )
        end

        def attribute(name)
          configuration.attributes.fetch(name.to_sym) {raise(Error::ResourceAttributeNotFound, :name => name, :materializer => self)}
        end

        def relation(name)
          configuration.relations.fetch(name.to_sym) {raise(Error::ResourceRelationshipNotFound, :name => name, :materializer => self)}
        end
      end
    end
  end
end
