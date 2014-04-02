package AWS::EMR;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

sub job {
  my $self = shift;
  return AWS::EMR::Job->new( Service => $self, @_ );
  }

sub jobs {
  my $self = shift;

  my $resp = $self->DescribeJobFlows->call->response_as_hash;
  
  my @jobs;
  for my $j (@{$resp->{DescribeJobFlowsResult}{JobFlows}{member}}) {
    push @jobs, $self->job( JobFlow => $j );
    }
  return @jobs;
  }

our $__PACKAGE__ = {
  'operations' => {
    'RunJobFlow' => {
      'required' => {
        'Instances' => 1,
        'Name' => 1
      },
      'optional' => {
        'LogUri' => 1,
        'Steps' => 1
      }
    },
    'TerminateJobFlows' => {
      'required' => {
        'JobFlowIds' => 1
      }
    },
    'DescribeJobFlows' => {
      'optional' => {
        'CreatedAfter' => 1,
        'JobFlowStates' => 1,
        'CreatedBefore' => 1,
        'JobFlowIds' => 1
      }
    },
    'AddJobFlowSteps' => {
      'required' => {
        'JobFlowId' => 1,
        'Steps' => 1
      }
    }
  },
  'wsdl' => 'http://elasticmapreduce.amazonaws.com/doc/2009-03-31/ElasticMapReduce.wsdl',
  'version' => '2009-03-31',
  'endpoint' => 'https://elasticmapreduce.amazonaws.com/'
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
        Operation=> '$_',
        \%params,
        );

      return \$self;
      }
    }
    unless __PACKAGE__->can( $_ );
  }

package AWS::EMR::Job;

sub new {
  my $class = shift;

  my $self = { @_ };

  die "Must provide AWS::EMR Service" unless ref $self->{Service} eq 'AWS::EMR';
  bless $self, $class;

  $self->_update_from_jobflow if $self->{JobFlow};

  return $self;
  }

sub service {
  my $self = shift;
  return $self->{Service};
  }

sub start {
  my $self = shift;
  
  if ($self->{Steps}) {
    $self->AddSteps( @{$self->{Steps}} );
    undef $self->{Steps};
    }

  $self->_update_from_jobflow(
    $self->service->call->response_as_hash
    );
  return $self;
  }

sub stop {
  my $self = shift;
  
  $self->service->clear;
  $self->service->TerminateJobFlows(
    'JobFlowIds.member.1'=>$self->{JobFlowId},
    )->call;
  return $self;
  }

sub state {
  my $self = shift;

  $self->refresh unless $self->{JobFlow};
  return $self->{JobFlow}{ExecutionStatusDetail}{State};
  }

sub refresh {
  my $self = shift;

  if ($self->{JobFlowId}) {
    $self->service->clear;
    my $resp = $self->service->DescribeJobFlows(
      'JobFlowIds.member.1'=>$self->{JobFlowId},
      )->call->response_as_hash;
    $self->_update_from_jobflow(
      $resp->{DescribeJobFlowsResult}{JobFlows}{member} );
    }
  return $self;
  }

sub done {
  my $self = shift;

  my %complete = (
    'COMPLETED' => 1,
    'FAILED' => 2,
    'TERMINATED' => 3,
    );
  $self->refresh;
  return $complete{$self->state};
  }

sub success {
  my $self = shift;

  if ($self->state eq 'COMPLETED') {
    for my $step (@{$self->{JobFlow}{Steps}{member}}) {
      return 0 unless $step->{ExecutionStatusDetail}{State} eq 'COMPLETED';
      }
    return 1;
    }
  return 0; # Still running
  }

sub donewait {
  my $self = shift;
  
  while (not $self->done) {
    sleep 600;
    }
  return $self->success;
  }

sub _update_from_jobflow {
  my $self = shift;
  my $jobflow = shift;

  $self->{JobFlow} = $jobflow if $jobflow;
  if ($self->{JobFlow} and $self->{JobFlow}{ExecutionStatusDetail}) {
    $self->{JobFlowId} = $self->{JobFlow}{JobFlowId};
  } elsif ($self->{JobFlow}{RunJobFlowResult}) {
    $self->{JobFlowId} = $self->{JobFlow}{RunJobFlowResult}{JobFlowId};
    }
  }

sub EMRJob {
  my $self = shift;
  my %params = @_;

  # Set up LogUri if we have an s3 bucket and none is specified.
  $params{LogUri} ||= "s3://" . $self->service->{s3_bucket} . "/log/"
    if $self->service->{s3_bucket};
  $params{'Instances.Ec2KeyName'} ||=  $self->{aws_keyname}
    if $self->{aws_keyname};

  if (0) { # Interactive job
    $params{'Instances.KeepJobFlowAliveWhenNoSteps'} = 'true';
    $params{Name} ||= 'interactive job';
    warn 'No SSH Key' unless $params{'Instances.Ec2KeyName'};
    }

  $self->service->RunJobFlow(
    Name => 'emr job',
    'Instances.MasterInstanceType' => 'm1.small',
    'Instances.SlaveInstanceType' => 'm1.small',
    'Instances.InstanceCount' => 1,
    'Instances.HadoopVersion' => '0.20',
    # ContentType => 'JSON',
    %params
    );

  return $self;
  }

sub EMRAddSteps {
  my $self = shift;

  $self->service->clear;
  $self->service->AddJobFlowSteps(
    JobFlowId => $self->{JobFlowId},
    );
  }

sub HiveJob {
  my $self = shift;
  my %params = @_;

  my $args = delete $params{Args};
  my $hivesite = delete $params{hive_site};
  $self->EMRJob(%params);

  $self->step( Name => 'Setup Hive', Args => [
    's3://us-east-1.elasticmapreduce/libs/hive/hive-script',
    '--base-path=s3://us-east-1.elasticmapreduce/libs/hive/',
    '--install-hive',
    ] );

  $self->step( Name => 'Install Hive Site', Args => [
    's3://us-east-1.elasticmapreduce/libs/hive/hive-script',
    '--base-path=s3://us-east-1.elasticmapreduce/libs/hive/',
    '--install-hive-site',
    '--hive-site=' . $hivesite
    ] ) if $hivesite;

  $self->RunHiveScript( 'Run Hive Script', @$args ) if ($args);

  return $self;
  }

sub RunHiveScript {
  my $self = shift;
  my $name = shift;

  return $self->step( Name => $name, 
    ActionOnFailure => 'TERMINATE_JOB_FLOW',
    Args => [
      's3://us-east-1.elasticmapreduce/libs/hive/hive-script',
      '--base-path=s3://us-east-1.elasticmapreduce/libs/hive/',
      '--run-hive-script',
      '--args',
      @_
      ] ) if (@_);

  return undef;
  }

sub AddSteps {
  my $self = shift;
  my @steps = @_;

  my $i = 1;
  for my $step (@steps) {
    my $key = "Steps.member.$i.";
    while (my ($k, $v) = each %$step) {
      $self->service->query_add( $key . $k, $v );
      }
    $i++;
    }
  return $self;
  }

sub step {
  my $self = shift;
  my %args = @_;

  $args{ActionOnFailure} ||= 'CONTINUE';
  $args{Jar} ||= 's3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar';
  my %step;
  @step{qw{Name ActionOnFailure
    HadoopJarStep.Jar HadoopJarStep.MainClass}}
    = @args{qw{Name ActionOnFailure Jar MainClass}};
  my $i = 1;
  for (@{$args{Args}}) {
    $step{'HadoopJarStep.Args.member.' . $i} = $_;
    $i++;
    }
  push @{$self->{Steps}}, \%step;
  return %step;
  }

package AWS::EMR::Step;



1; # Magic true value required at end of module
__END__

=head1 NAME

AWS::EMR - EMR class for AWS interfaces

=head1 VERSION

This document describes AWS::EMR version 0.0.3

=head1 SYNOPSIS

    use AWS::EMR;

    my $emr = AWS::EMR->new();
  
=head1 DESCRIPTION

    REST interface to AWS Elastic Map Reduce.


=head1 INTERFACE 

=over

=item EMRJob

    Set up an EMR Job.

=back

=head1 DIAGNOSTICS

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
