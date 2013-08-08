# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require 'version.rb'

Gem::Specification.new do |s|
	s.name			= 'vagrant-git'
	s.version		= VagrantGit::VERSION
	s.platform		= Gem::Platform::RUBY
	s.authors		= ['Daniel Bryan']
	s.license		= 'MIT'
	s.email			= ['danbryan@gmail.com']
	s.homepage		= 'https://github.com/Learnosity/vagrant-git'
	s.summary		= %q{A vagrant plugin to allow checking out git repositories as part of vagrant tasks.}
	s.description	= %q{A vagrant plugin to allow checking out git repositories as part of vagrant tasks.}
	s.files = ['lib/vagrant-git.rb']
	s.require_paths = ['lib']

	s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
	
	if s.respond_to? :specification_version
		current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
		s.specification_version = 2
	end

	s.add_development_dependency 'bundler', '>= 1.2.0'
	s.add_development_dependency 'vagrant', '>= 1.2'

end
