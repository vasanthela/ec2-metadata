require 'net/http'

module Ec2Metadata
  DEFAULT_HOST = "169.254.169.254".freeze

  autoload :Base, 'ec2_metadata/base'
  autoload :NamedBase, 'ec2_metadata/named_base'
  autoload :Root, 'ec2_metadata/root'
  autoload :Revision, 'ec2_metadata/revision'
  autoload :Dummy, 'ec2_metadata/dummy'

  DEFAULT_REVISION = 'latest'

  class << self
    def instance
      @instance ||= Root.new
    end

    def clear_instance
      @instance = nil
    end

    def [](key)
      instance[key]
    end

    def to_hash(revision = DEFAULT_REVISION)
      self[revision].to_hash
    end

    def from_hash(hash, revision = DEFAULT_REVISION)
      # hash = {revision => hash}
      # instance.from_hash(hash)
      rev_obj = instance.new_child(revision)
      instance.instance_variable_set(:@children, {revision => rev_obj})
      instance.instance_variable_set(:@child_keys, [revision])
      rev_obj.from_hash(hash)
    end

    def get(path)
      logging("Ec2Metadata.get(#{path.inspect})") do
        Net::HTTP.get(DEFAULT_HOST, path)
      end
    end

    def formalize_key(key)
      key.to_s.gsub(/_/, '-')
    end

    def logging(msg)
      @indent ||= 0
      disp = (" " * @indent) << msg
      # puts(disp) 
      @indent += 2
      begin
        result = yield
      ensure
        @indent -= 2
      end
      # puts "#{disp} => #{result.inspect}"
      result
    end
  end

  class NotFoundError < StandardError
  end

end

unless ENV['EC2_METADATA_DUMMY_DISABLED'] =~ /yes|true|on/i
  Ec2Metadata::Dummy.search_and_load_yaml
end
