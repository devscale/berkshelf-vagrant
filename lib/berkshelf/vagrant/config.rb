module Berkshelf
  module Vagrant
    # @author Jamie Winsor <reset@riotgames.com>
    class Config < ::Vagrant.plugin("2", :config)
      include Berkshelf::Vagrant::EnvHelpers

      # @return [String]
      #   path to the Berksfile to use with Vagrant
      attr_reader :berksfile_path

      # @return [Array<Symbol>]
      #   only cookbooks in these groups will be installed and copied to
      #   Vagrant's shelf
      attr_accessor :only

      # @return [Array<Symbol>]
      #   cookbooks in all other groups except for these will be installed
      #   and copied to Vagrant's shelf
      attr_accessor :except

      # @return [String]
      #   the Chef node name (client name) to use to authenticate with the remote
      #   chef server to upload cookbooks when using the chef client provisioner
      attr_accessor :node_name

      # @return [String]
      #   a filepath to a chef client key to use to authenticate with the remote
      #   chef server to upload cookbooks when using the chef client provisioner
      attr_accessor :client_key

      def initialize
        super

        @berksfile_path = File.join(Dir.pwd, Berkshelf::DEFAULT_FILENAME)
        @except         = Array.new
        @only           = Array.new
        @node_name      = Berkshelf::Config.instance.chef.node_name
        @client_key     = Berkshelf::Config.instance.chef.client_key
      end

      # @param [String] value
      def berksfile_path=(value)
        @berksfile_path = File.expand_path(value)
      end

      # @param [String] value
      def client_key=(value)
        @client_key = File.expand_path(value)
      end

      alias_method :to_hash, :instance_variables_hash

      def validate(machine)
        errors = Array.new

        if machine.config.berkshelf.berksfile_path.nil?
          errors << "berkshelf.berksfile_path cannot be nil."
        end

        unless File.exist?(machine.config.berkshelf.berksfile_path)
          errors << "No Berskfile was found at #{machine.config.berkshelf.berksfile_path}."
        end

        if !except.empty? && !only.empty?
          errors << "A value for berkshelf.empty and berkshelf.only cannot both be defined."
        end

        if chef_client?(machine.env)
          if machine.config.berkshelf.node_name.nil?
            errors << "A configuration must be set for chef.node_name when using the chef_client provisioner. Run 'berks configure' or edit your configuration."
          end

          if machine.config.berkshelf.client_key.nil?
            errors << "A configuration must be set for chef.client_key when using the chef_client provisioner. Run 'berks configure' or edit your configuration."
          end
        end

        { "berkshelf configuration" => errors }
      end
    end
  end
end
