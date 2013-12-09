require 'vagrant-git/git'

module VagrantPlugins
  module VagrantGit
    module Action
      class HandleRepos
        def initialize(app, env)
          @app = app
          @env = env
        end

        def call(env)
          @app.call(env)
          @env = env

          @vm = env[:machine]

          @vm.config.git.to_hash[:repos].each do |rc|
            if not rc.clone_in_host
              raise 'NotImplemented: clone_in_host=>false'
            end

            if File.exist? "#{rc.path}/.git"
              if rc.sync_on_load
                Git::fetch(rc.path)
                Git::pull(rc.path, {:branch => rc.branch})
              end
            else
              p = Git::clone(rc.target, rc.path, {:branch => rc.branch})
              if p.success? and rc.set_upstream
                @vm.ui.info("Clone done - setting upstream of #{rc.path} to #{rc.set_upstream}")
                if not Git::set_upstream(rc.path, rc.set_upstream).success?
                  @vm.ui.error("WARNING: Failed to change upstream to #{rc.set_upstream} in #{rc.path}")
                end
              else
                @vm.ui.error("WARNING: Failed to clone #{rc.target} into #{rc.path}")
              end
              if File.exist? "#{rc.path}/.gitmodules"
                p = Git::submodule(rc.path)
                if p.success?
                  @vm.ui.info("Checked out submodules.")
                else
                  @vm.ui.error("WARNING: Failed to check out submodules for #{path}")
                end
              end
            end
          end
        end
      end
    end
  end
end
