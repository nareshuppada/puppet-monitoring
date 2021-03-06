# Class: monitoring
#
# Autodetects installed services supported for monitoring,
# and roll out checks for these services
#
# @see https://onpuppet.github.io/puppet-monitoring Monitoring
# @see https://www.github.com/onpuppet/puppet-monitoring Github
# @see https://forge.puppet.com/onpuppet/puppet-monitoring Puppet Forge
#
# @author Jon Skarpeteig <jon.skarpeteig@gmail.com>
#
# @param collectd_network_server_hostname Optional[String] Hostname of CollectD network server (E.G InfluxDB). Leaving this parameter empty skips CollectD entirely. Default value: ''
# @param collectd_network_server_port Optional[Integer[0, 65535]] Port used by CollectD network server. Valid options: unsigned shortint digit. Default value: undef
# @param plugins_location [String] Location of sensu plugins. Default value: /opt/sensu/embedded/bin/
# @param sensu_rabbitmq_hostname Optional[String] RabbitMQ hostname used by Sensu server. Leaving this parameter empty skips Sensu entirely. Default value: ''
# @param sensu_rabbitmq_password Optional[String] RabbitMQ hostname used by Sensu server. Default value: 'guest'
#
class monitoring (
  Optional[String] $collectd_network_server_hostname,
  Optional[String] $collectd_network_server_port,
  Optional[String] $sensu_plugins_location,
  Optional[String] $sensu_rabbitmq_hostname,
  Optional[String] $sensu_rabbitmq_password,
  Optional[String] $sensu_rabbitmq_vhost,
) {

  # Ensure facts refresh monitoring tools are applied last
  # Would rather use custom stages instead, but stages doesn't support subclasses
  # https://tickets.puppetlabs.com/browse/PUP-1108
  refacter { 'monitoring':
    patterns => [
      '^apache_',
      '^centrify_',
      '^collectd_',
      '^cuda_',
      '^elasticsearch_',
      '^influxdb_',
      '^iscdhcp_',
      '^mysql_',
      '^ntpd_',
      '^postfix_',
      '^rabbitmq_',
      '^redis_',
    ],
  }

  Package <| title != 'collectd' and title != 'sensu' |> {
    before +> Class['monitoring::install'],
    notify +> Refacter['monitoring']
  }

  Service <| title != 'collectd' and title != 'sensu' |> {
    before +> Class['monitoring::install'],
    notify +> Refacter['monitoring']
  }

  include ::monitoring::install
}
