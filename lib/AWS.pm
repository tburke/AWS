package AWS;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

our %_default = (
  aws_account => '',
  aws_secret  => '',
  aws_keyname => '',
  s3_bucket => '',
  );

sub new {
  my $class = shift;
  my %args = @_;

  my $self = { %_default, @_ };

  bless $self, $class;

  $self->_init(@_);

  return $self;
  }

sub _init {
  }

sub default_parameters {
  my $self = shift;
 
  my %params; 
  for (keys %_default) {
    $params{$_} = $self->{$_};
    }
  return %params;
  }

sub AS {
  my $self = shift;
  use AWS::AS;

  return AWS::AS->new( $self->default_parameters );
  }

sub CW {
  my $self = shift;
  use AWS::CW;

  return AWS::CW->new( $self->default_parameters );
  }

sub EC2 {
  my $self = shift;
  use AWS::EC2;

  return AWS::EC2->new( $self->default_parameters );
  }

sub ELB {
  my $self = shift;
  use AWS::ELB;

  return AWS::ELB->new( $self->default_parameters );
  }

sub EMR {
  my $self = shift;
  use AWS::EMR;

  return AWS::EMR->new( $self->default_parameters, @_ );
  }

sub S3 {
  my $self = shift;
  use AWS::S3;

  return AWS::S3->new( $self->default_parameters );
  }

sub SDB {
  my $self = shift;
  use AWS::SDB;

  return AWS::SDB->new( $self->default_parameters );
  }

1; # Magic true value required at end of module

__END__

=head1 NAME

AWS - Perl access to AWS services.

=head1 VERSION

This document describes AWS version 0.0.3

=head1 SYNOPSIS

    use AWS;

    my $ec2 = AWS->new( aws_account => 'KKK', aws_secret => 'SSS' )->EC2;
  
=head1 DESCRIPTION

    AWS wraps the Amazon Web Services REST interfaces.


=head1 INTERFACE 

=over

=item AS

    AutoScale

=item CW

    CloudWatch

=item EC2

    ElasticComputeCloud

=item ELB

    ElasticLoadBalancing

=item EMR

    ElasticMapReduce

=item S3

    Simple Storage Service

=item SDB

    SimpleDB

=item default_parameters

    default_parameters

=item new

    new

=back

=head1 DIAGNOSTICS

=over

=item C<< CLEAR Not implemented >>

Bucket tied hash response does not implement CLEAR.

=back


=head1 CONFIGURATION AND ENVIRONMENT

AWS requires no configuration files or environment variables.


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
