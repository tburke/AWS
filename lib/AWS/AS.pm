package AWS::AS;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

our $__PACKAGE__ = {
  'operations' => {
    'DescribeScalingActivities' => {
      'required' => {
        'AutoScalingGroupName' => 1
      },
      'optional' => {
        'NextToken' => 1,
        'MaxRecords' => 1,
        'ActivityIds' => 1
      }
    },
    'DeleteLaunchConfiguration' => {
      'required' => {
        'LaunchConfigurationName' => 1
      }
    },
    'DescribeAutoScalingGroups' => {
      'optional' => {
        'AutoScalingGroupNames' => 1
      }
    },
    'CreateLaunchConfiguration' => {
      'required' => {
        'ImageId' => 1,
        'InstanceType' => 1,
        'LaunchConfigurationName' => 1
      },
      'optional' => {
        'KeyName' => 1,
        'RamdiskId' => 1,
        'BlockDeviceMappings' => 1,
        'UserData' => 1,
        'KernelId' => 1,
        'SecurityGroups' => 1
      }
    },
    'DeleteTrigger' => {
      'required' => {
        'AutoScalingGroupName' => 1,
        'TriggerName' => 1
      }
    },
    'CreateAutoScalingGroup' => {
      'required' => {
        'MaxSize' => 1,
        'AvailabilityZones' => 1,
        'MinSize' => 1,
        'LaunchConfigurationName' => 1,
        'AutoScalingGroupName' => 1
      },
      'optional' => {
        'LoadBalancerNames' => 1,
        'Cooldown' => 1
      }
    },
    'UpdateAutoScalingGroup' => {
      'required' => {
        'AutoScalingGroupName' => 1
      },
      'optional' => {
        'MaxSize' => 1,
        'AvailabilityZones' => 1,
        'MinSize' => 1,
        'LaunchConfigurationName' => 1,
        'Cooldown' => 1
      }
    },
    'DeleteAutoScalingGroup' => {
      'required' => {
        'AutoScalingGroupName' => 1
      }
    },
    'DescribeLaunchConfigurations' => {
      'optional' => {
        'NextToken' => 1,
        'MaxRecords' => 1,
        'LaunchConfigurationNames' => 1
      }
    },
    'DescribeTriggers' => {
      'required' => {
        'AutoScalingGroupName' => 1
      }
    },
    'TerminateInstanceInAutoScalingGroup' => {
      'required' => {
        'InstanceId' => 1,
        'ShouldDecrementDesiredCapacity' => 1
      }
    },
    'SetDesiredCapacity' => {
      'required' => {
        'DesiredCapacity' => 1,
        'AutoScalingGroupName' => 1
      }
    },
    'CreateOrUpdateScalingTrigger' => {
      'required' => {
        'UpperThreshold' => 1,
        'LowerBreachScaleIncrement' => 1,
        'Dimensions' => 1,
        'BreachDuration' => 1,
        'Period' => 1,
        'MeasureName' => 1,
        'AutoScalingGroupName' => 1,
        'Statistic' => 1,
        'TriggerName' => 1,
        'LowerThreshold' => 1,
        'UpperBreachScaleIncrement' => 1
      },
      'optional' => {
        'Namespace' => 1,
        'CustomUnit' => 1,
        'Unit' => 1
      }
    }
  },
  'wsdl' => 'http://autoscaling.us-east-1.amazonaws.com/doc/2009-05-15/AutoScaling.wsdl',
  'version' => '2009-05-15',
  'endpoint' => 'https://autoscaling.amazonaws.com'
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

__END__

=head1 NAME

AWS::AS - Perl access to AWS AutoScale services.

=head1 VERSION

This document describes AWS::AS version 0.0.3

=head1 SYNOPSIS

    use AWS;

    my $as = AWS->new( aws_account => 'KKK', aws_secret => 'SSS' )->AS;
  
=head1 DESCRIPTION

    AWS::AS wraps the Amazon Web Services AutoScale REST interfaces.

=head1 INTERFACE 

=over

=item AS

    AutoScale

=back

