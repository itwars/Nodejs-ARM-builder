Vagrant::Config.run do |config|
  config.vm.box = "base"
  #config.vm.box_url = "~/precise64.box"
  #config.vm.box_url = "http://files.vagrantup.com/quantal64.box"

  config.vm.share_folder("cross-compiler", "~/cross-compiler", ".")

  # Allow symlinks
  config.vm.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/cross-compiler", "1"]
  # Otherwise the compile will go into swap, making things slow
  config.vm.customize ["modifyvm", :id, "--memory", 2048]
  # Setup virtual machine
  config.vm.provision :shell, :inline => "./cross-compiler/cross-compiler.sh"
end
