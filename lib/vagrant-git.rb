begin
	require 'vagrant'
rescue LoadError
	raise 'The Vagrant Git plugin must be run within Vagrant.'
end

module VagrantGit
	VERSION = "0.0.6"
	module Ops
		class << self
			def clone(target, path, opts = {})
				branch = opts[:branch]
				if branch.nil?
					system("git clone '#{target}' '#{path}'")
				else
					system("git clone -b '#{branch}' '#{target}' '#{path}'")
				end
			end
			def fetch(path)
				system("cd '#{path}'; git fetch")
			end

			def pull(path, opts = {})
				branch = opts[:branch]
				if branch.nil?
					system("cd '#{path}'; git fetch; git pull;")
				else
					system("cd '#{path}'; git pull origin '#{branch}';")
				end
			end

			def set_upstream(path, target)
				system("cd '#{path}'; git remote set-url origin '#{target}';")
			end
		end
	end

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

		def call(env)
			vm = env[:machine]
			vm.config.git.to_hash[:repos].each do |rc|
				if not rc.clone_in_host
					# TODO
					raise 'NotImplemented: clone_in_host=>false'
				end

				if File.exist? rc.path + '/.git'
					if rc.sync_on_load
						VagrantGit::Ops::fetch(rc.path)
						VagrantGit::Ops::pull(rc.path, {:branch => rc.branch})
					end
				else
					VagrantGit::Ops::clone(rc.target, rc.path, {:branch => rc.branch})
					if rc.set_upstream
						vm.ui.info("Clone done - setting upstream of #{rc.path} to #{rc.set_upstream}")
						VagrantGit::Ops::set_upstream(rc.path, rc.set_upstream)
					end
				end
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
end
