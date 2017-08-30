# set up workers
class basics::worker {

  motd_message = 'This is a worker VM'

  file { '/etc/motd':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('basics/motd.erb'),
  }
}
