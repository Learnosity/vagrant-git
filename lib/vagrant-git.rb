begin
    require "vagrant"
rescue LoadError
    raise "The Vagrant Hello plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.2.0"
    raise "The Vagrant Hello plugin is only compatible with Vagrant 1.2+"
end

require "vagrant-git/plugin"

require "pathname"

module VagrantPlugins
  module VagrantGit
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end

    #I18n.load_path << File.expand_path('locales/en.yml', source_root)
    #I18n.reload!

  end
end
