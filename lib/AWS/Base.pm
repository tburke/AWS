package AWS::Base;

use LWP;
use URI::QueryParam;
use URI::Escape qw(uri_escape_utf8);
use DateTime;
use Digest::SHA qw(hmac_sha256_base64);
use XML::Simple;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

our %_default = (
  aws_account => '',
  aws_secret  => '',
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

sub secret {
  my $self = shift;
  return $self->{aws_secret};
  }

sub account {
  my $self = shift;
  return $self->{aws_account};
  }

sub endpoint {
  my $self = shift;
  return $self->_package_hash->{endpoint};
  }

sub version {
  my $self = shift;
  return $self->_package_hash->{version};
  }

sub clear {
  my $self = shift;
  return $self->{request} = HTTP::Request->new(GET => $self->endpoint);
  }

sub request {
  my $self = shift;
  return $self->{request} ||= HTTP::Request->new(GET => $self->endpoint);
  }

sub method {
  my $self = shift;
  return $self->request->method;
  }

sub uri {
  my $self = shift;
  return $self->request->uri;
  }

sub query_add {
  my $self = shift;
  my %param = @_;

  while (my ($k, $v) = each %param) {
    $self->uri->query_param( $k, $v );
    }
  }

sub sign {
  my $self = shift;

  $self->query_add( 
    AWSAccessKeyId => $self->account(),
    SignatureVersion => 2,
    SignatureMethod => 'HmacSHA256',
    Timestamp =>
      DateTime->from_epoch( epoch => $self->request->date || time ) . '.000Z',
    );

  my $final =
    join("\n", $self->method, $self->uri->authority, $self->uri->path, '');

  for my $key (sort $self->uri->query_param) {
    $final .= $key . '=' 
      .  uri_escape_utf8( $self->uri->query_param( $key ) , '^A-Za-z0-9_.-' )
      . '&';
    }
  chop $final;
  $final =~ s/\+/\%20/g;
  $self->uri->query_param( Signature =>
    hmac_sha256_base64( $final, $self->secret() ) . '=' );

  }

sub call {
  my $self = shift;

  $self->sign;

  $self->{response} = LWP::UserAgent->new->request( $self->request, @_ );

  return $self;
  }

sub response_as_hash {
  my $self = shift;

  return XML::Simple::XMLin( $self->{response}->content )
    if ($self->{response} and $self->{response}->is_success);
  return undef;
  }

1; # Magic true value required at end of module
__END__

=head1 NAME

AWS::Base - Base class for AWS interfaces


=head1 VERSION

This document describes AWS version 0.0.3


=head1 SYNOPSIS

    use AWS::Base;

    Base class for AWS.
  
  
=head1 DESCRIPTION

    AWS::Base is the base class for AWS interfaces.

=head1 INTERFACE 

=over

=item account

    account accessor.

=item call

    Sign and call the Amazon service.

=item endpoint

    Return the service endpoint.

=item method

    Return the HTTP method.

=item new

    Creator.

=item query_add

    Add parameters to the URI.

=item request

    Return the request object.

=item response_as_hash

    Parse the response XML into a hash.

=item secret

    Return the secret.

=item sign

    Sign the request.

=item uri

    Return the uri.

=item version

    Return the service version.

=back

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
