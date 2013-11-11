#!/bin/bash
set -x

# 注意:
# - ローカル開発を前提としているので、セキュリティの設定などは行なっていない
# - httpd, iptables の設定は上書きされるので、ゲスト OS 内でカスタマイズしている場合注意

# yum でのパッケージのインストール・更新は日本のミラーのみ利用 (時間短縮のため)
sudo sed -ie "s/^#include_only=.*/include_only=.jp/" /etc/yum/pluginconf.d/fastestmirror.conf

#yum update -y

# 共通パッケージ
yum install -y "http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm"
yum install -y "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
yum install -y ntp
yum install -y git
yum install -y vim-enhanced
chkconfig ntpd on

# httpd
yum install -y httpd
yum install -y mod_ssl
chkconfig httpd on

# vagrant 用 httpd 設定。設定は上書きされるので、カスタムする場合は注意
# /vagrant_data/www/public がデフォルトの公開ディレクトリになる。
# /vagrant_data/*/public で *.dev ドメインの利用も想定している
cat << EOS > /etc/httpd/conf.d/00-vagrant.conf
NameVirtualHost *:80
<Directory "/vagrant_data/*/public">
        Options -Indexes
        AllowOverride All
        # http://docs-v1.vagrantup.com/v1/docs/config/vm/share_folder.html
        EnableSendfile Off
</Directory>
<VirtualHost *:80>
        ServerName any
        DocumentRoot /vagrant_data/www/public
</VirtualHost>
<VirtualHost *:80>
        ServerName any
        ServerAlias *.dev
        VirtualDocumentRoot /vagrant_data/%1/public
</VirtualHost>
EOS

# php
yum install -y php php php-pear php-pdo php-mysql php-xml php-mbstring php-gd php-intl php-pecl-apc pcre
yum install -y php-pecl-xdebug

# php 追加パッケージ
# (EPELを利用。デフォルトで EPEL が有効なので、enablerepo の指定は不要だが、明示的にするため付与)
yum install -y --enablerepo=epel php-mcrypt php-phpunit-PHPUnit php-pear-Mail-Mime php-pear-Mail-mimeDecode php-pear-Mail php-pecl-mailparse

service httpd restart


# Firewall (iptables) の設定
cat << EOS > /etc/sysconfig/iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT

EOS
service iptables restart


yum install -y mysql-server
service mysqld restart
chkconfig mysqld on
echo "CREATE DATABASE dev;" | mysql


# composer
if [ ! -e /usr/local/bin/composer ]; then
	curl -sS https://getcomposer.org/installer | php
	mv composer.phar /usr/local/bin/composer
else
	/usr/local/bin/composer self-update
fi


cat << EOS

###########################################################################
#
# TO INSTALL LARAVEL:
#
# [host  ]$ vagrant ssh
# [guest ]$ cd /vagrant_data
# [guest ]$ composer create-project laravel/laravel --prefer-dist www
#
###########################################################################

EOS


# PHP 5.4
# yum update --enablerepo=remi
