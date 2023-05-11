module FakerMaker
  module Auditable

    def audit(instance)
      envelope = { timestamp: Time.now.getutc.to_f, body: instance.as_json }
      audit_stream.puts(JSON.generate(envelope))
      audit_stream.flush
    rescue => exception
      warn "Warning: #{exception.class}: \"#{exception.message}\" occurred. FakerMaker will disable audit logging. Further warnings supressed."
      FakerMaker.configuration.audit = false
    end

    private

    def audit_stream
      destination = FakerMaker.configuration.audit_destination
      return destination if destination.is_a? IO

      file_destination = File.new(destination, 'a')
      FakerMaker.configuration.audit_destination = file_destination
    end
  end
end
