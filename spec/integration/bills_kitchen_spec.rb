
require_relative '../helpers'

describe "bills kitchen" do

  include Helpers

  describe "tools" do
    it "installs ChefDK 0.5.0.rc.2" do
      run_cmd("chef -v").should match('Chef Development Kit Version: 0.5.0.rc.2')
    end
    it "installs Vagrant 1.7.2" do
      run_cmd("vagrant -v").should match('1.7.2')
    end
    it "installs Terraform 0.4.0" do
      run_cmd("terraform --version").should match('0.4.0')
    end
    it "installs Packer 0.7.5" do
      run_cmd("packer version").should match('0.7.5')
    end
    it "installs Consul 0.5.0" do
      run_cmd("consul --version").should match('0.5.0')
    end
    it "installs ssh.exe" do
      run_cmd("ssh -V").should match('OpenSSH_6.0p1, OpenSSL 1.0.1c 10 May 2012')
    end
    it "installs rsync.exe" do
      run_cmd("rsync --version").should match('rsync  version 3.0.9')
    end
    it "installs Git 1.9" do
      run_cmd("git --version").should match('git version 1.9.5')
    end
    it "installs kdiff3" do
      marker_file = "#{BUILD_DIR}/merged.md"
      begin
        run_cmd("kdiff3 README.md README.md --auto -cs LineEndStyle=0 -o #{marker_file}")
        File.exist?(marker_file).should be true
      ensure
        File.delete(marker_file) if File.exist?(marker_file)
      end
    end
    it "installs clink 0.4.4" do
      run_cmd("#{BUILD_DIR}/tools/clink/clink.bat version").should match('Clink v0.4.4')
    end
    it "installs atom 0.189.0" do
      # see https://github.com/atom/atom-shell/issues/683
      # so we 1) ensure the atom.cmd is on the PATH and 2) it's the right version
      cmd_succeeds "#{BUILD_DIR}/tools/atom/Atom/resources/cli/atom.cmd -v"
      cmd_succeeds "grep '0.189.0' #{BUILD_DIR}/tools/atom/Atom/resources/app/package.json"
    end
    it "installs apm 0.157.0" do
      run_cmd("#{BUILD_DIR}/tools/atom/Atom/resources/app/apm/bin/apm.cmd -v").should match('0.157.0')
    end
  end

  describe "environment" do
    it "sets HOME to W:/home" do
      env_match "HOME=#{BUILD_DIR}/home"
    end
    it "sets VAGRANT_HOME to W:/home/.vagrant.d" do
      env_match "VAGRANT_HOME=#{BUILD_DIR}/home/.vagrant.d"
    end
    it "sets VBOX_USER_HOME to %USERPROFILE%" do
      env_match "VBOX_USER_HOME=#{ENV['USERPROFILE']}"
    end
    it "sets TERM=cygwin" do
      env_match "TERM=cygwin"
    end
    it "sets ANSICON=true" do
      env_match "ANSICON=true"
    end
    it "sets SSL_CERT_FILE to W:/home/cacert.pem" do
      env_match "SSL_CERT_FILE=#{BUILD_DIR}/home/cacert.pem"
    end
  end

  describe "aliases" do
    it "aliases `bundle exec` to `be`" do
      run_cmd("doskey /macros").should match('be=bundle exec $*')
    end
    it "aliases `atom` to `vi`" do
      run_cmd("doskey /macros").should match('vi=atom.cmd $*')
    end
  end

  describe "ruby installations" do

    describe "chefdk as the primary ruby" do
      it "provides the default `ruby` command" do
        run_cmd("which ruby").should match(convert_slashes("#{CHEFDK_RUBY}/bin/ruby.EXE"))
      end
      it "provides the default `gem` command" do
        run_cmd("which gem").should match(convert_slashes("#{CHEFDK_RUBY}/bin/gem"))
      end
    end

    describe "chefdk ruby" do
      it "installs Chef 12.2.0" do
        run_cmd("knife -v").should match('Chef: 12.2.0')
      end
      it "has RubyGems > 2.4.1 installed (fixes opscode/chef-dk#242)" do
        run_cmd("gem -v").should match('2.4.4')
      end
      it "uses $HOME/.chefdk as the gemdir" do
        run_cmd("#{CHEFDK_RUBY}/bin/gem environment gemdir").should match("#{CHEFDK_HOME}/gem/ruby/2.0.0")
      end
      it "does not have any binaries in the $HOME/.chefdk gemdir preinstalled when we ship it" do
        # because since RubyGems > 2.4.1 the ruby path in here is absolute!
        Dir["#{CHEFDK_HOME}/gem/ruby/2.0.0/bin"].should be_empty
      end
      it "has ChefDK verified to work via `chef verify`" do
        cmd_succeeds "chef verify"
      end
      it "has 'bundler (1.7.12)' gem installed" do
        gem_installed "bundler", "1.7.12"
      end
      it "has 'knife-audit (0.2.0)' plugin installed" do
        knife_plugin_installed "knife-audit", "0.2.0"
      end
      it "has 'knife-server (1.1.0)' plugin installed" do
        knife_plugin_installed "knife-server", "1.1.0"
      end
    end

    describe "vagrant ruby" do
      it "has 'vagrant-toplevel-cookbooks (0.2.4)' plugin installed" do
        vagrant_plugin_installed "vagrant-toplevel-cookbooks", "0.2.4"
      end
      it "has 'vagrant-omnibus (1.4.1)' plugin installed" do
        vagrant_plugin_installed "vagrant-omnibus", "1.4.1"
      end
      it "has 'vagrant-cachier (1.2.0)' plugin installed" do
        vagrant_plugin_installed "vagrant-cachier", "1.2.0"
      end
      it "has 'vagrant-berkshelf (4.0.3)' plugin installed" do
        vagrant_plugin_installed "vagrant-berkshelf", "4.0.3"
      end
      it "installed vagrant plugins $HOME/.vagrant.d" do
        Dir.entries("#{VAGRANT_HOME}/gems/gems").should include('vagrant-toplevel-cookbooks-0.2.4')
      end
    end

    describe "atom plugins" do
      it "has 'sublime-tabs' plugin installed" do
        atom_plugin_installed "sublime-tabs"
      end
      it "has 'atom-beautify' plugin installed" do
        atom_plugin_installed "atom-beautify"
      end
      it "has 'minimap' plugin installed" do
        atom_plugin_installed "minimap"
      end
      it "has 'line-ending-converter' plugin installed" do
        atom_plugin_installed "line-ending-converter"
      end
      it "has 'language-chef' plugin installed" do
        atom_plugin_installed "language-chef"
      end
      it "has 'language-batchfile' plugin installed" do
        atom_plugin_installed "language-batchfile"
      end
      it "has 'autocomplete-plus' plugin installed" do
        atom_plugin_installed "autocomplete-plus"
      end
      it "has 'autocomplete-snippets' plugin installed" do
        atom_plugin_installed "autocomplete-snippets"
      end
    end
  end
end
