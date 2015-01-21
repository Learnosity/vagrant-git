module VagrantPlugins
  module VagrantGit
    class Plugin < Vagrant.plugin("2")
      name "vagrant git support"
      description <<-DESC 
    A vagrant plugin to allow checking out git repositories as part of 
    vagrant tasks.
      DESC

      config(:git) do
        require File.expand_path("../config", __FILE__)
        Config
      end

      require File.expand_path("../action", __FILE__)
      %w{up reload}.each do |action|
        action_hook(:git, "machine_action_#{action}".to_sym) do |hook|
          hook.before(
            Vagrant::Action::Builtin::Provision,
            Action::HandleRepos
          )
        end
      end
    end
  end
end
