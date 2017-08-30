# set up main host / controller
class basics::controller {

  motd_message = 'This is the controller VM'

  file { '/etc/motd':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('basics/motd.erb'),
  }
}
