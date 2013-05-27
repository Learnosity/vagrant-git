# vagrant-git

`vagrant-git` is a [Vagrant](http://vagrantup.com) plugin for checkig out and updating git repos. It has a very simple configuration to either clone or pull repositories after a VM boots (but before it's provisioned).

Currently the plugin only supports cloning into the host machine, so care should be taken to clone the repositories into a directory accessible by the guest. [vagrant-sparseimage](https://github.com/Learnosity/vagrant-sparseimage) integrates well for this use job, or a standard file share should be use.

When you run `vagrant up` or `vagrant provision`, this plugin will clone or pull the various specified git repos. It does not attempt to handle a dirty working tree: `git pull` will simply fail. This is to prevent mistakenly clobbering any changes. In order to get a 

Planning to implement a command - `vagrant git` - supporting `list`, `pull`, `clone` and `reset` to streamline this a little.

## Dependencies
Only supports Vagrant > 1.2.

Requires `git`.

## Installation

See **building** below for building the gem.

Use `vagrant plugin` to install the gem in your Vagrant environment:

```bash
$ vagrant plugin install vagrant-git.gem
```

## Configuration

See `example-box/vagrantfile` for an example configuration.

The following config properties for `config.git` are required:

* **target**: *string*: the repository to clone. This must be a fully qualified git ref spec.
* **path**: *string*: the path in the host or the guest to clone or pull the repo into

The following property is optional (but not yet supported):

* **clone_in_host**: *boolean*: true to execute git commands in the host, false to execute them in the guest

## Building

```bash
$ bundle install
$ gem build vagrant-sparseimage.gemspec
```
