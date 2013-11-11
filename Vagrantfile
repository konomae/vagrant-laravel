# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos64"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  # config.vm.network :forwarded_port, guest: 8000, host: 8081

  # デフォルトで /vagrant が存在する。/vagrant は Vagrantfile (このファイル) と同じ場所が見える
  # /vagrant を利用しても良いが、アクセス件などを設定したいので、カスタムで下記を追加する
  config.vm.synced_folder "vagrant_data/", "/vagrant_data", :owner => 'vagrant', :group => 'vagrant', :mount_options => ["dmode=777","fmode=776"]

  # Ref: http://serverfault.com/a/496612
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # 初回 vagrant up 時に実行される
  # もう一度実行するときは vagrant provision する
  config.vm.provision :shell, :path => "provision.sh"

end
