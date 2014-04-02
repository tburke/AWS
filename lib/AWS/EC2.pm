package AWS::EC2;

use MIME::Base64 qw(encode_base64);

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

# $u->RunInstances(ImageId=>"ami-a51ff3cc",KeyName=>"","SecurityGroup.1"=>"dwetl")->run

use base qw(AWS::Base);

sub RunInstances {
  my $self = shift;
  my %params = @_;

  die "Must provide an ami" unless $params{ImageId};

  $params{'KeyName'} ||=  $self->{aws_keyname}
    if $self->{aws_keyname};

  $params{UserData} = encode_base64($params{UserData}) 
    if $params{UserData};

  $self->query_add(
    Action   => 'RunInstances',
    Version  => $self->version,
    MaxCount => 1,
    MinCount => 1,
    %params,
    );

  return $self;
  }

our $__PACKAGE__ = {
  'operations' => {
    'ConfirmProductInstance' => {
      'required' => {
        'instanceId' => 1,
        'productCode' => 1
      }
    },
    'DescribeKeyPairs' => {
      'required' => {
        'keySet' => 1
      }
    },
    'AuthorizeSecurityGroupIngress' => {
      'required' => {
        'ipPermissions' => 1,
        'userId' => 1,
        'groupName' => 1
      }
    },
    'CreateVpnConnection' => {
      'required' => {
        'customerGatewayId' => 1,
        'vpnGatewayId' => 1,
        'type' => 1
      }
    },
    'DescribeSubnets' => {
      'optional' => {
        'filterSet' => 1,
        'subnetSet' => 1
      }
    },
    'StopInstances' => {
      'required' => {
        'instancesSet' => 1
      },
      'optional' => {
        'force' => 1
      }
    },
    'DescribeReservedInstancesOfferings' => {
      'optional' => {
        'instanceType' => 1,
        'productDescription' => 1,
        'availabilityZone' => 1,
        'reservedInstancesOfferingsSet' => 1
      }
    },
    'DeleteVpnConnection' => {
      'required' => {
        'vpnConnectionId' => 1
      }
    },
    'RegisterImage' => {
      'required' => {
        'name' => 1
      },
      'optional' => {
        'architecture' => 1,
        'kernelId' => 1,
        'blockDeviceMapping' => 1,
        'description' => 1,
        'rootDeviceName' => 1,
        'ramdiskId' => 1,
        'imageLocation' => 1
      }
    },
    'CreateSpotDatafeedSubscription' => {
      'required' => {
        'bucket' => 1,
        'prefix' => 1
      }
    },
    'DescribeSecurityGroups' => {
      'required' => {
        'securityGroupSet' => 1
      }
    },
    'TerminateInstances' => {
      'required' => {
        'instancesSet' => 1
      }
    },
    'DisassociateAddress' => {
      'required' => {
        'publicIp' => 1
      }
    },
    'DeregisterImage' => {
      'required' => {
        'imageId' => 1
      }
    },
    'DeleteDhcpOptions' => {
      'required' => {
        'dhcpOptionsId' => 1
      }
    },
    'CreateVolume' => {
      'required' => {
        'availabilityZone' => 1
      },
      'optional' => {
        'snapshotId' => 1,
        'size' => 1
      }
    },
    'CancelSpotInstanceRequests' => {
      'required' => {
        'spotInstanceRequestIdSet' => 1
      }
    },
    'ModifySnapshotAttribute' => {
      'required' => {
        'createVolumePermission' => 1,
        'snapshotId' => 1
      }
    },
    'DescribeSnapshots' => {
      'required' => {
        'snapshotSet' => 1
      },
      'optional' => {
        'ownersSet' => 1,
        'restorableBySet' => 1
      }
    },
    'StartInstances' => {
      'required' => {
        'instancesSet' => 1
      }
    },
    'ReleaseAddress' => {
      'required' => {
        'publicIp' => 1
      }
    },
    'CreateCustomerGateway' => {
      'required' => {
        'ipAddress' => 1,
        'type' => 1,
        'bgpAsn' => 1
      }
    },
    'GetPasswordData' => {
      'required' => {
        'instanceId' => 1
      }
    },
    'CreateDhcpOptions' => {
      'required' => {
        'dhcpConfigurationSet' => 1
      }
    },
    'DescribeVolumes' => {
      'required' => {
        'volumeSet' => 1
      }
    },
    'CreateKeyPair' => {
      'required' => {
        'keyName' => 1
      }
    },
    'PurchaseReservedInstancesOffering' => {
      'required' => {
        'instanceCount' => 1,
        'reservedInstancesOfferingId' => 1
      }
    },
    'DescribeImages' => {
      'required' => {
        'imagesSet' => 1
      },
      'optional' => {
        'ownersSet' => 1,
        'executableBySet' => 1
      }
    },
    'ResetSnapshotAttribute' => {
      'required' => {
        'snapshotId' => 1
      }
    },
    'DeleteSecurityGroup' => {
      'required' => {
        'groupName' => 1
      }
    },
    'DeleteVpc' => {
      'required' => {
        'vpcId' => 1
      }
    },
    'GetConsoleOutput' => {
      'required' => {
        'instanceId' => 1
      }
    },
    'DescribeVpnConnections' => {
      'optional' => {
        'filterSet' => 1,
        'vpnConnectionSet' => 1
      }
    },
    'DescribeVpnGateways' => {
      'optional' => {
        'filterSet' => 1,
        'vpnGatewaySet' => 1
      }
    },
    'DescribeAddresses' => {
      'required' => {
        'publicIpsSet' => 1
      }
    },
    'DescribeReservedInstances' => {
      'optional' => {
        'reservedInstancesSet' => 1
      }
    },
    'ModifyImageAttribute' => {
      'required' => {
        'productCodes' => 1,
        'launchPermission' => 1,
        'description' => 1,
        'imageId' => 1
      }
    },
    'DeleteCustomerGateway' => {
      'required' => {
        'customerGatewayId' => 1
      }
    },
    'DescribeSpotPriceHistory' => {
      'optional' => {
        'productDescriptionSet' => 1,
        'instanceTypeSet' => 1,
        'endTime' => 1,
        'startTime' => 1
      }
    },
    'CreateSubnet' => {
      'required' => {
        'cidrBlock' => 1,
        'vpcId' => 1
      },
      'optional' => {
        'availabilityZone' => 1
      }
    },
    'DeleteSnapshot' => {
      'required' => {
        'snapshotId' => 1
      }
    },
    'CreateSnapshot' => {
      'required' => {
        'volumeId' => 1
      },
      'optional' => {
        'description' => 1
      }
    },
    'DescribeSpotInstanceRequests' => {
      'required' => {
        'spotInstanceRequestIdSet' => 1
      }
    },
    'AllocateAddress' => {},
    'ResetInstanceAttribute' => {
      'required' => {
        'instanceId' => 1
      }
    },
    'DescribeInstances' => {
      'required' => {
        'instancesSet' => 1
      }
    },
    'DetachVpnGateway' => {
      'required' => {
        'vpcId' => 1,
        'vpnGatewayId' => 1
      }
    },
    'DeleteSpotDatafeedSubscription' => {},
    'DetachVolume' => {
      'required' => {
        'volumeId' => 1
      },
      'optional' => {
        'instanceId' => 1,
        'device' => 1,
        'force' => 1
      }
    },
    'DescribeRegions' => {
      'required' => {
        'regionSet' => 1
      }
    },
    'DescribeCustomerGateways' => {
      'optional' => {
        'filterSet' => 1,
        'customerGatewaySet' => 1
      }
    },
    'AttachVpnGateway' => {
      'required' => {
        'vpcId' => 1,
        'vpnGatewayId' => 1
      }
    },
    'CancelBundleTask' => {
      'required' => {
        'bundleId' => 1
      }
    },
    'DeleteSubnet' => {
      'required' => {
        'subnetId' => 1
      }
    },
    'AttachVolume' => {
      'required' => {
        'volumeId' => 1,
        'instanceId' => 1,
        'device' => 1
      }
    },
    'ModifyInstanceAttribute' => {
      'required' => {
        'instanceId' => 1,
        'userData' => 1,
        'ramdisk' => 1,
        'disableApiTermination' => 1,
        'kernel' => 1,
        'instanceType' => 1,
        'instanceInitiatedShutdownBehavior' => 1,
        'blockDeviceMapping' => 1
      }
    },
    'DescribeSpotDatafeedSubscription' => {},
    'CreateSecurityGroup' => {
      'required' => {
        'groupDescription' => 1,
        'groupName' => 1
      }
    },
    'DescribeSnapshotAttribute' => {
      'required' => {
        'snapshotId' => 1
      }
    },
    'DeleteKeyPair' => {
      'required' => {
        'keyName' => 1
      }
    },
    'RevokeSecurityGroupIngress' => {
      'required' => {
        'ipPermissions' => 1,
        'userId' => 1,
        'groupName' => 1
      }
    },
    'CreateVpc' => {
      'required' => {
        'cidrBlock' => 1
      }
    },
    'RequestSpotInstances' => {
      'required' => {
        'launchSpecification' => 1,
        'spotPrice' => 1
      },
      'optional' => {
        'validUntil' => 1,
        'instanceCount' => 1,
        'launchGroup' => 1,
        'availabilityZoneGroup' => 1,
        'type' => 1,
        'validFrom' => 1
      }
    },
    'AssociateAddress' => {
      'required' => {
        'publicIp' => 1,
        'instanceId' => 1
      }
    },
    'MonitorInstances' => {
      'required' => {
        'instancesSet' => 1
      }
    },
    'UnmonitorInstances' => {
      'required' => {
        'instancesSet' => 1
      }
    },
    'CreateImage' => {
      'required' => {
        'instanceId' => 1,
        'name' => 1
      },
      'optional' => {
        'noReboot' => 1,
        'description' => 1
      }
    },
    'BundleInstance' => {
      'required' => {
        'instanceId' => 1,
        'storage' => 1
      }
    },
    'DeleteVolume' => {
      'required' => {
        'volumeId' => 1
      }
    },
    'AssociateDhcpOptions' => {
      'required' => {
        'vpcId' => 1,
        'dhcpOptionsId' => 1
      }
    },
    'DescribeAvailabilityZones' => {
      'required' => {
        'availabilityZoneSet' => 1
      }
    },
    'DescribeImageAttribute' => {
      'required' => {
        'imageId' => 1
      }
    },
    'DescribeDhcpOptions' => {
      'optional' => {
        'dhcpOptionsSet' => 1
      }
    },
    'CreateVpnGateway' => {
      'required' => {
        'type' => 1
      },
      'optional' => {
        'availabilityZone' => 1
      }
    },
    'DeleteVpnGateway' => {
      'required' => {
        'vpnGatewayId' => 1
      }
    },
    'ResetImageAttribute' => {
      'required' => {
        'imageId' => 1
      }
    },
    'DescribeBundleTasks' => {
      'required' => {
        'bundlesSet' => 1
      }
    },
    'DescribeVpcs' => {
      'optional' => {
        'filterSet' => 1,
        'vpcSet' => 1
      }
    },
    'DescribeInstanceAttribute' => {
      'required' => {
        'instanceId' => 1
      }
    },
    'RunInstances' => {
      'required' => {
        'minCount' => 1,
        'maxCount' => 1,
        'instanceType' => 1,
        'groupSet' => 1,
        'imageId' => 1
      },
      'optional' => {
        'additionalInfo' => 1,
        'kernelId' => 1,
        'placement' => 1,
        'userData' => 1,
        'keyName' => 1,
        'disableApiTermination' => 1,
        'subnetId' => 1,
        'monitoring' => 1,
        'instanceInitiatedShutdownBehavior' => 1,
        'blockDeviceMapping' => 1,
        'addressingType' => 1,
        'ramdiskId' => 1
      }
    },
    'RebootInstances' => {
      'required' => {
        'instancesSet' => 1
      }
    }
  },
  'wsdl' => 'http://ec2.amazonaws.com/doc/2009-11-30/',
  'version' => '2009-11-30',
  'endpoint' => 'https://ec2.amazonaws.com/'
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

AWS::EMR - EMR class for AWS interfaces


=head1 VERSION

This document describes AWS::EMR version 0.0.1


=head1 SYNOPSIS

    use AWS::EMR;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
AWS::EMR requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-aws@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Thomas Burke  C<< <tburke@tb99.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Thomas Burke C<< <tburke@tb99.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
