module JSONAPI
  module Materializer
    module Resource
      require_relative("resource/attribute")
      require_relative("resource/relation")
      require_relative("resource/relationship")
      require_relative("resource/configuration")

      extend(ActiveSupport::Concern)
      include(ActiveModel::Model)

      attr_accessor(:object)
      attr_writer(:selects)
      attr_writer(:includes)
      attr_writer(:context)
      attr_reader(:raw)

      def initialize(**keyword_arguments)
        super(**keyword_arguments)

        @raw = keyword_arguments

        context.validate!
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
          mapping.
            select {|_, value| value.visible}.
            slice(*selects.dig(type))
        else
          mapping.
            select {|_, value| value.visible}
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

      def context
        self.class.const_get("Context").new(**@context || {})
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
        unless const_defined?("Collection")
          self::Collection = Class.new do
            include(JSONAPI::Materializer::Collection)
          end
        end

        unless const_defined?("Context")
          self::Context = Class.new do
            include(JSONAPI::Materializer::Context)

            def initialize(**keyword_arguments)
              keyword_arguments.keys.each(&singleton_class.method(:attr_accessor))

              super(**keyword_arguments)
            end
          end
        end

        @attributes = {}
        @relations = {}

        validates_presence_of(:object)

        origin(JSONAPI::Materializer.configuration.default_origin)
        identifier(JSONAPI::Materializer.configuration.default_identifier)

        has(JSONAPI::Materializer.configuration.default_identifier)
      end

      class_methods do
        def identifier(value)
          @identifier = value.to_sym
        end

        def origin(value)
          @origin = value
        end

        def type(value)
          @type = value.to_sym
        end

        def has(name, from: name, visible: true)
          @attributes[name] = Attribute.new(
            :owner => self,
            :name => name,
            :from => from,
            :visible => visible
          )
        end

        def has_one(name, from: name, class_name:, visible: true)
          @relations[name] = Relation.new(
            :owner => self,
            :type => :one,
            :name => name,
            :from => from,
            :class_name => class_name,
            :visible => visible
          )
        end

        def has_many(name, from: name, class_name:, visible: true)
          @relations[name] = Relation.new(
            :owner => self,
            :type => :many,
            :name => name,
            :from => from,
            :class_name => class_name,
            :visible => visible
          )
        end

        def context
          const_get("Context")
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
          configuration.attributes.fetch(name.to_sym) {raise(Error::ResourceRelationshipNotFound, :name => name, :materializer => self)}
        end

        def relation(name)
          configuration.relations.fetch(name.to_sym) {raise(Error::ResourceRelationshipNotFound, :name => name, :materializer => self)}
        end
      end
    end
  end
end
