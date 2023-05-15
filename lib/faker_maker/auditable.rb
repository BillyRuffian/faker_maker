# frozen_string_literal: true

# FakerMaker module for generating Fakes
module FakerMaker
  # Mix-in module which provides the auditable functionality
  module Auditable
    def audit(instance)
      envelope = audit_envelope(class: instance.class.name, body: instance.as_json)
      audit_stream.puts(JSON.generate(envelope))
      audit_stream.flush if audit_stream.respond_to?(:flush)
    rescue StandardError => e
      warn "FakerMaker Warning: #{e.class}: \"#{e.message}\" occurred. FakerMaker will disable audit logging. " \
           'Further warnings supressed.'
      FakerMaker.configuration.audit = false
    end

    private

    def audit_stream
      destination = FakerMaker.configuration.audit_destination
      return destination if destination.respond_to?(:puts)

      file_destination = File.new(destination, 'a')
      FakerMaker.configuration.audit_destination = file_destination
    end

    def audit_envelope(**overrides)
      {
        timestamp: DateTime.now.iso8601,
        factory: name.to_s,
        **overrides
      }
    end
  end
end
