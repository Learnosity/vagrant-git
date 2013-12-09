module VagrantPlugins
  module VagrantGit
    module Git
      class << self
        # Run the command, wait for exit and return the Process object.
        def run(cmd)
          pid = Process.fork { exec(cmd) }
          Process.waitpid(pid)
          return $?
        end

        def clone(target, path, opts = {})
          branch = opts[:branch]
          if branch.nil?
            return run("git clone '#{target}' '#{path}'")
          else
            return run("git clone -b '#{branch}' '#{target}' '#{path}'")
          end
        end
        def fetch(path)
          return run("cd '#{path}'; git fetch")
        end

        def pull(path, opts = {})
          branch = opts[:branch]
          if branch.nil?
            return run("cd '#{path}'; git fetch; git pull;")
          else
            return run("cd '#{path}'; git pull origin '#{branch}';")
          end
        end

        def submodule(path)
          return run("cd '#{path}' && git submodule update --init --recursive")
        end

        def set_upstream(path, target)
          return run("cd '#{path}'; git remote set-url origin '#{target}';")
        end
      end
    end
  end
end
