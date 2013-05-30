begin
	require 'vagrant'
rescue LoadError
	raise 'The Vagrant Git plugin must be run within Vagrant.'
end

module VagrantGit
	VERSION = "0.0.2"
	class Plugin < Vagrant.plugin("2")
		name "vagrant git support"
		description "A vagrant plugin to allow checking out git repositories as part of vagrant tasks."

		config(:git) do
			Config
		end

		action_hook(self::ALL_ACTIONS) do |hook|
			hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, HandleRepos)
		end
	end

	class HandleRepos
		# Action to either clone or pull git repos
		def initialize(app, env); end 

		def git_clone(target, path, branch)
			if branch.nil?
				system("git clone '#{target}' '#{path}'")
			else
				system("git clone -b '#{branch}' '#{target}' '#{path}'")
			end
		end

		def git_pull(path, branch)
			if branch.nil?
				system("cd '#{path}'; git fetch; git pull;")
			else
				system("cd '#{path}'; git fetch; git pull origin '#{branch}';")
			end
		end

		def call(env)
			vm = env[:machine]
			vm.config.git.to_hash[:repos].each do |rc|
				if not rc.clone_in_host
					# TODO
					raise 'NotImplemented: clone_in_host=>false'
				end

				if File.exist? rc.path
					git_pull(rc.path, rc.branch)
				else
					git_clone(rc.target, rc.path, rc.branch)
				end
			end
		end
	end

	class RepoConfig
		# Config for a single repo
		# Assumes that the agent has permission to check out, or that it's public

		attr_accessor :target, :path, :clone_in_host, :branch

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
		end
	end

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
	end
end
