Vagrant.configure("2") do |config|
  # Base OS Image
  config.vm.box = "generic/fedora35"
  
  # Configure VM
  config.vm.provider "libvirt" do |provider|
    provider.memory = 8192
    provider.cpus = 2
  end

  provisioning_path = "/home/vagrant/.dotfiles"

  # Sync current working dir with VM
  config.vm.synced_folder ".", provisioning_path, type: "rsync" 
  
  # Run Ansible provisioning 
  config.vm.provision "ansible_local" do |ansible|
    ansible.provisioning_path = provisioning_path
    ansible.playbook = "main.yml"
    ansible.galaxy_role_file = "requirements.yml"
    ansible.galaxy_command = "ansible-galaxy collection install -r %{role_file}"
  end

  # Enable GDM to provide a full desktop environment
  config.vm.provision "shell", inline: <<-GUI
    dnf update -y > /dev/null
    dnf install gdm -y > /dev/null
    systemctl enable gdm
    systemctl start gdm
  GUI

end

