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
          errors = {}

          @vm.config.git.to_hash[:repos].each do |rc|
            errors[rc.path] = []
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
                  err = "Failed to change upstream to #{rc.set_upstream} in #{rc.path}"
                  errors[rc.path].push(err)
                  @vm.ui.error(err)
                end
              else !p.success?
                err = "Failed to clone #{rc.target} into #{rc.path}"
                errors[rc.path].push(err)
                @vm.ui.error(err)
              end

              if File.exist? "#{rc.path}/.gitmodules"
                p = Git::submodule(rc.path)
                if p.success?
                  @vm.ui.info("Checked out submodules.")
                else
                  err ="WARNING: Failed to check out submodules for #{rc.path}"
                  errors[rc.path].push(err)
                  @vm.ui.error(err)
                end
              end
            end
          end

          # Reprint any errors
          errors = errors.reject { |k, v| v.length == 0 }
          if errors.length > 0
            @vm.ui.error("WARNING: Encountered errors when cloning repos.")
            errors.each do |repo, errs|
              @vm.ui.error("-- #{repo} --")
              errs.each do |e|
                @vm.ui.error(e)
              end
            end
            @vm.ui.error("If these were due to transient network issues, try again with:")
            @vm.ui.error("\tvagrant halt")
            @vm.ui.error("\tvagrant up")
          end
        end
      end
    end
  end
end
