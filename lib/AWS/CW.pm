package AWS::CW;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

our $__PACKAGE__ = {
  'operations' => {
    'GetMetricStatistics' => {
      'required' => {
        'Statistics' => 1,
        'EndTime' => 1,
        'StartTime' => 1,
        'MeasureName' => 1,
        'Period' => 1
      },
      'optional' => {
        'Namespace' => 1,
        'Dimensions' => 1,
        'CustomUnit' => 1,
        'Unit' => 1
      }
    },
    'ListMetrics' => {
      'optional' => {
        'NextToken' => 1
      }
    }
  },
  'wsdl' => 'http://monitoring.amazonaws.com/doc/2009-05-15/CloudWatch.wsdl',
  'version' => '2009-05-15',
  'endpoint' => 'https://monitoring.amazonaws.com'
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
