require "egree/reference_id"

module Egree
  class Case
    def self.signature_types
      [ "sms", "electronicid", "touch", "quickintent", "signbyhand" ]
    end

    def self.generate_reference_id
      ReferenceId.generate
    end

    attr_reader :name, :signature_types, :case_id

    def initialize name, signature_types, options = {}
      @name = name
      @case_id = options.delete(:case_id)
      self.signature_types = signature_types
    end

    attr_writer :reference_id

    def reference_id
      @reference_id ||= self.class.generate_reference_id
    end

    def signature_types= signature_types
      types = Array(signature_types)

      unknown_types = types - Case.signature_types
      if unknown_types.any?
        raise unknown_signature_type_error(unknown_types)
      end

      @signature_types = types
    end

    def add_party party
      self.parties << party
    end

    def parties
      @parties ||= []
    end

    def add_document document
      self.documents << document
    end

    def documents
      @documents ||= []
    end

    private

    def unknown_signature_type_error types
      ArgumentError.new("Unknown signature types: #{types.join(", ")}. Valid types are: #{Case.signature_types.join(", ")}")
    end
  end
end
