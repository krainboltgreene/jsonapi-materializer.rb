# frozen_string_literal: true

module JSONAPI
  module Materializer
    module Resource
      class Relation
        include(ActiveModel::Model)

        attr_accessor(:owner)
        attr_accessor(:name)
        attr_accessor(:type)
        attr_accessor(:from)
        attr_accessor(:class_name)

        validates_presence_of(:owner)
        validates_presence_of(:name)
        validates_presence_of(:type)
        validates_presence_of(:from)
        validates_presence_of(:class_name)

        def initialize(**keyword_arguments)
          super(**keyword_arguments)

          validate!
        end

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        def for(subject)
          @for ||= {}
          @for[checksum(subject)] ||= case type
                                      when :many
                                        unlessing(fetch_relation(subject), -> { subject.includes.any? { |included| included.include?(from.to_s) } || fetch_relation(subject).loaded? }) do |subject|
                                          subject.select(:id)
                                        end.map do |related_object|
                                          materializer_class.new(
                                            **subject.raw,
                                            object: related_object
                                          )
                                        end
                                      when :one
                                        if fetch_relation(subject).present?
                                          materializer_class.new(
                                            **subject.raw,
                                            object: fetch_relation(subject)
                                          )
                                        end
                                      end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

        def using(parent)
          Resource::Relationship.new(related: self, parent:)
        end

        def many?
          type == :many
        end

        def one?
          type == :one
        end

        private

        def fetch_relation(subject)
          @fetch_relationship ||= {}
          @fetch_relationship[checksum(subject)] ||= subject.object.public_send(from)
        end

        def materializer_class
          class_name.constantize
        end

        def unlessing(object, proc)
          if proc.call
            object
          else
            yield(object)
          end
        end

        def checksum(subject)
          [
            from,
            materializer_class,
            name,
            owner,
            subject,
            type
          ].hash
        end
      end
    end
  end
end
