package AWS::S3;

use Digest::SHA qw(hmac_sha1_base64);

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

# S3 signatures, rather than AWS Version 2.
sub sign {
  my $self = shift;

  $self->request->date(time) unless $self->request->date;
  my $path = $self->uri->path;
  my @headers;
  for (sort grep {/^x-amz-/i} $self->request->header_field_names) {
    push @headers, lc $_ . ":" . $self->request->header($_)
    }
  
  my $final =
    join("\n", $self->method, 
      $self->request->header('Content-MD5') || '',
      $self->request->content_type || '',
      $self->request->header('Date'),
      @headers, 
      $path || '/',
      );
  $self->request->header('Authorization' =>
    'AWS ' . $self->account . ':' .
    hmac_sha1_base64( $final, $self->secret() ) . '=' );

  }

sub buckets {
  my $self = shift;

  my @buckets;

  # GET the service, parse result XML into bucket objects.
  $self->call;
  for my $bucket (@{$self->response_as_hash->{Buckets}{Bucket}}) {
    push @buckets, AWS::S3::Bucket->new(
      aws_account => $self->account,
      aws_secret => $self->secret,
      %$bucket );
    }
  return @buckets;
  }

our $__PACKAGE__ = {
  wsdl => 'http://doc.s3.amazonaws.com/2006-03-01/AmazonS3.wsdl',
  endpoint => 'http://s3.amazonaws.com/',
  version => '2006-03-01',
};

sub _package_hash {
  return $__PACKAGE__;
  }

package AWS::S3::Bucket;

use base qw(AWS::S3);

sub new {
  my $class = shift;
  my %args = @_;

  my $self = { %args };
  bless $self, $class;

  $self->uri->path( $self->{Name} );

  return $self;
  }

sub objects {
  my $self = shift;
  # Return a tied hash

  $self->call;
  my $hash = $self->response_as_hash;
  
  return $self;
  }

sub fetch {}
sub store {}
sub delete {}
sub exists {}

package AWS::S3::Bucket::Hash;

sub TIEHASH {
  my $self = shift;
  my $bucket = shift;

  my $node = {
    BUCKET => $bucket,
    MARKER => '',
    TRUNCATED => 0,
    LIST => {},
    };

  return bless $node, $self;
  }

sub FETCH {
  my $self = shift;
  my $key = shift;

  return $self->{LIST}->{$key}
    if $self->{LIST}->{$key};
  return $self->{BUCKET}->fetch( $key );
  }

sub STORE {
  my $self = shift;
  my $key = shift;
  my $value = shift;

  return $self->{BUCKET}->store( $key, $value );
  }

sub DELETE {
  my $self = shift;
  my $key = shift;

  delete $self->{LIST}->{ $key };
  return $self->{BUCKET}->delete( $key );
  }

sub CLEAR {
  my $self = shift;

  warn "CLEAR not implemented";
  }

sub EXISTS {
  my $self = shift;
  my $key = shift;

  return exists $self->{LIST}->{$key} || 
    $self->{BUCKET}->exists( $key );
  }

sub FIRSTKEY {
  my $self = shift;
  }

sub NEXTKEY {
  my $self = shift;
  my $key = shift;
  }

sub SCALAR {
  my $self = shift;
  }

sub UNTIE {
  my $self = shift;
  }

sub DESTROY {
  my $self = shift;
  }

package AWS::S3::Object;

1; # Magic true value required at end of module
__END__

=head1 NAME

AWS::S3 - S3 class for AWS interfaces


=head1 VERSION

This document describes AWS::S3 version 0.0.1


=head1 SYNOPSIS

    use AWS::S3;

    my $s3 = AWS::S3->new(aws_key => 'KKK', aws_secret => 'SSS');
    my @buckets = $s3->buckets;
    my ($bucket) = $s3->buckets( 'bucket' );
    while (my ($key, $object) = each $bucket->objects) {
      }

  
=head1 DESCRIPTION

AWS::S3 is a perl wrapper around the Amazon S3 REST interface. It configures an HTTP::Request object and provides helper funcitons for common use cases.

Amazon's S3 service is composed of a hierarchy of objects -- Service, Bucket and Object -- on which one can perform REST operations (GET, PUT, POST, DELETE, HEAD). Each object has sub-resources that may be accessed such as acl, location, logging, versioning, versions, requestPayment and torrent.



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
  
AWS::S3 requires no configuration files or environment variables.


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
