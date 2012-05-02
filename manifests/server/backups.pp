# Loosely based on https://github.com/lelutin/puppet-mysql/blob/master/manifests/server/cron/backup.pp 
class mysql::server::backups {

  $real_mysql_backup_dir = $mysql_backup_dir ? {
    '' => '/var/backups/mysql',
    default => $mysql_backup_dir,
  }

  file { 'mysql_backup_dir':
    path   => $real_mysql_backup_dir,
    ensure => directory,
    before => Cron['mysql_backup_cron'],
    owner  => root, 
    group  => 0, 
    mode   => 0700;
  }

  file { 'mysql_backup_cron_file':
    path => "$real_mysql_backup_dir/cron.sh",    
    mode => 0770,
    content => "#!/bin/bash\n/usr/bin/mysqldump -uroot -p${mysql_root_password} --default-character-set=utf8 --all-databases --all --flush-logs --lock-tables --single-transaction | /bin/gzip > ${real_mysql_backup_dir}/mysqldump`date '+%F_%H-%M-%S'`.sql.gz > /tmp/mysql_cron_output 2&>1",
  }

  cron { "mysql_backup_cron" :
    command => "/bin/bash $real_mysql_backup_dir/cron.sh",
    user => 'root',
    minute => 00,
    hour => 01,
    require => [ Class["mysql::server"], File["mysql_backup_cron_file"]],
  }

}