Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.enable :apt
  end

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    # vb.customize ["modifyvm", :id, "--monitorcount", "2"]
    # vb.customize ["modifyvm", :id, '--audio', 'dsound', '--audiocontroller', 'ac97']
  end

  config.vm.network "private_network", ip: "192.168.33.10"

  ## https://stackoverflow.com/a/53363591

  # https://askubuntu.com/questions/1067929/on-18-04-package-virtualbox-guest-utils-does-not-exist
  config.vm.provision "shell", inline: "sudo apt-add-repository multiverse && sudo apt-get update"

  config.vm.provision "shell", inline: "sudo apt-get upgrade -y"

  # Install xfce
  config.vm.provision "shell", inline: "sudo apt-get install -y xfce4"

  # Install virtualbox-guest-additions
  # (Not sure if these packages could be helpful as well: virtualbox-guest-utils-hwe virtualbox-guest-x11-hwe)
  #config.vm.provision "shell", inline: "virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11"
  # Instead of these outdated packages, run:
  # $ vagrant plugin install vagrant-vbguest
  
  # Permit anyone to start the GUI
  config.vm.provision "shell", inline: "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"

  # Optional: Use LightDM login screen (-> not required to run "startx")
  config.vm.provision "shell", inline: "sudo apt-get install -y lightdm lightdm-gtk-greeter"
  # Optional: Install a more feature-rich applications menu
  config.vm.provision "shell", inline: "sudo apt-get install -y xfce4-whiskermenu-plugin"

  config.vm.provision "shell", inline: <<-SHELL
    # apt-get update -q
    su - vagrant
    wget -q https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    chmod +x miniconda.sh

    ./miniconda.sh -b -p /home/vagrant/miniconda
    echo 'export PATH="/home/vagrant/miniconda/bin:$PATH"' >> /home/vagrant/.bashrc
    source /home/vagrant/.bashrc
    chown -R vagrant:vagrant /home/vagrant/miniconda
    /home/vagrant/miniconda/bin/conda install conda-build anaconda-client anaconda-build -y -q
    # sudo cp /home/vagrant/miniconda.sh /opt/miniconda.sh
  SHELL

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl enable docker

    sudo apt-get install -y python3-pip
    sudo pip3 install --upgrade pip virtualenvwrapper pipsi
    sudo pipsi install docker-compose
  SHELL
end
