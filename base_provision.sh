#! /bin/bash

# Install devtools.
# Among other things, this gets us an up to date version of GCC
wget http://people.centos.org/tru/devtools-1.1/devtools-1.1.repo -O /etc/yum.repos.d/devtools-1.1.repo
yum install -y devtoolset-1.1
ln -s /opt/centos/devtoolset-1.1/root/usr/bin/* /usr/bin/

# Add EPEL
# We use -U to update rather than install, so that this script can be
# run multiple times without incident.
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
# Add webtatic (more recent PHP)
rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm

# PHP, and necessary extensions
yum install -y php54w
yum install -y php54w-devel php54w-mcrypt php54w-gd php54w-pear php54w-soap
yum install -y php54w-pdo php54w-mysql

# PHP installs Apache2 as a dependency, and I don't know why.
# Having it installed is fine, but we need to stop it.
service httpd stop

# Basic PHP config
cp /tmp/server-config/etc/php.ini /etc/

# PHP-FPM, and config
yum install -y php54w-fpm
cp -r /tmp/server-config/etc/php-fpm.conf /etc/
service php-fpm start

# Installing percona, because it's better than MySQL
# It's not really better at dev load, but it's what we run on production
rpm -Uvh http://www.percona.com/redir/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
yum install -y Percona-Server-server-55
# cp /tmp/server-config/etc/my.cnf /etc/
mysql_install_db
service mysql start

# Install Nginx.
# We add the Nginx yum repository, because the default version is 1.0.1
rpm -Uvh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum install -y nginx
rm -rf /etc/nginx/conf.d
cp -r /tmp/server-config/etc/nginx/ /etc/
service nginx start

# Tools for development
yum install -y git vim-enhanced

# Compass, through rubygems
yum install -y ruby rubygems
gem update --system
gem install compass -v 0.12.7

# Composer
cd /usr/local/bin
curl -sS https://getcomposer.org/installer | php
chmod +x composer.phar

# Magerun
curl -o n98-magerun.phar https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar
chmod +x n98-magerun.phar

# Fabric
yum install -y python python-devel python-pip
pip install fabric

cp /tmp/server-config/home/vagrant/fabfile.py /home/vagrant/fabfile.py
cp /tmp/server-config/home/vagrant/compass_compile.sh /home/vagrant/

# User settings
# cp /tmp/server-config/home/vagrant/.bashrc /home/vagrant
cat /tmp/server-config/home/vagrant/.ssh/known_hosts >> /home/vagrant/.ssh/known_hosts
chown vagrant:vagrant /home/vagrant/.ssh/known_hosts

mkdir -p /var/www/magento
chown -R vagrant:vagrant /var/www/magento

