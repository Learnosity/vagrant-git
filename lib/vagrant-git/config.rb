module VagrantPlugins
  module VagrantGit
    class Config < Vagrant.plugin("2", :config)
      # Singleton for each VM
      @@repo_configs = []
      class << self
        attr_accessor :repo_configs
      end

      def to_hash
        { :repos => @@repo_configs }
      end

      def add_repo
        # Yield a new repo config object to the config block
        rc = RepoConfig.new
        yield rc
        @@repo_configs.push rc
      end

      def validate(machine)
        errors = {}
        @@repo_configs.each_with_index do |rc, i|
          rc_errors = rc.validate
          if rc_errors.length > 0
            errors[i] = rc_errors
          end
        end
        errors
      end

      def finalize!
        @@repo_configs.each do |config|
          config.finalize!
        end
      end
    end

    class RepoConfig
      # Config for a single repo
      # Assumes that the agent has permission to check out, or that it's public

      attr_accessor :target, :path, :clone_in_host, :branch, :sync_on_load, :set_upstream

      @@required = [:target, :path]

      def validate
        errors = {}
        if @target.nil?
          errors[:target] = ["target must not be nil."]
        end
        if @path.nil?
          errors[:path] = ["path must not be nil."]
        end
        errors
      end

      def finalize!
        if @clone_in_host.nil?
          @clone_in_host = true
        end
        if @sync_on_load.nil?
          @sync_on_load = false
        end
      end
    end
  end
end
