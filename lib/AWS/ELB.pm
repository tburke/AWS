package AWS::ELB;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

our $__PACKAGE__ = {
  'operations' => {
    'DeregisterInstancesFromLoadBalancer' => {
      'required' => {
        'LoadBalancerName' => 1,
        'Instances' => 1
      }
    },
    'CreateLoadBalancer' => {
      'required' => {
        'LoadBalancerName' => 1,
        'AvailabilityZones' => 1,
        'Listeners' => 1
      }
    },
    'DescribeLoadBalancers' => {
      'optional' => {
        'LoadBalancerNames' => 1
      }
    },
    'EnableAvailabilityZonesForLoadBalancer' => {
      'required' => {
        'LoadBalancerName' => 1,
        'AvailabilityZones' => 1
      }
    },
    'RegisterInstancesWithLoadBalancer' => {
      'required' => {
        'LoadBalancerName' => 1,
        'Instances' => 1
      }
    },
    'DescribeInstanceHealth' => {
      'required' => {
        'LoadBalancerName' => 1
      },
      'optional' => {
        'Instances' => 1
      }
    },
    'DisableAvailabilityZonesForLoadBalancer' => {
      'required' => {
        'LoadBalancerName' => 1,
        'AvailabilityZones' => 1
      }
    },
    'ConfigureHealthCheck' => {
      'required' => {
        'HealthCheck' => 1,
        'LoadBalancerName' => 1
      }
    },
    'DeleteLoadBalancer' => {
      'required' => {
        'LoadBalancerName' => 1
      }
    }
  },
  'wsdl' => 'http://elasticloadbalancing.amazonaws.com/doc/2009-05-15/ElasticLoadBalancing.wsdl',
  'version' => '2009-05-15',
  'endpoint' => 'https://elasticloadbalancing.amazonaws.com/'
};


sub _package_hash {
  return $__PACKAGE__;
  }

for (keys %{$__PACKAGE__->{operations}}) {
  eval qq{
    sub $_ {
      my \$self = shift;
      my \%params = \@_;

      \$self->query_add(
        Action   => '$_',
        Version  => \$self->version,
        \%params,
        );

      return \$self;
      }
    }
    unless __PACKAGE__->can( $_ );
  }

1; # Magic true value required at end of module
