use XML::LibXML;
use Data::Dumper;

my $file = shift;
my $schema = shift;
my $module;

if (-e $file) {
  local ($/) = undef;
  open my $fh, $file;
  $module = <$fh>;
  } elsif ($file and $schema) {
  $module = newmodule($file, $schema);
  } else {
  die "Usage: wsdl.pl file [schema]";
  }

($schema) ||= $module =~ /\s+'?wsdl'?\s+=>\s+'([^']+)',/;

# $d=XML::LibXML->load_xml(location=>"Downloads/2009-11-30.ec2.wsdl");

my $d=XML::LibXML->load_xml(location=> $schema);

my $root = $d->documentElement;
my $target = $root->getAttribute( 'targetNamespace' );
my $soap = $root
  ->lookupNamespacePrefix('http://schemas.xmlsoap.org/wsdl/soap/');
my $xs = $root
  ->lookupNamespacePrefix('http://www.w3.org/2001/XMLSchema');
my $tns = $root
  ->lookupNamespacePrefix($target);

my %service;
$service{wsdl} = $schema;
$service{endpoint} = $d->findvalue("//$soap:address/\@location");
($service{version}) = $target =~ /([\d\-]+)\/?$/;

for ($d->find("//$soap:operation/\@soapAction")->get_nodelist) {
  $operation = $_->value;
  next unless $operation;
  $service{operations}{$operation} = {};
  my $s = $d->find("//$xs:element[\@name='$operation']")->shift;
  if (my $type = $s->getAttribute( 'type' )) {
    $type =~ s/^\S+://;
    $s = $d->find("//$xs:complexType[\@name='$type']")->shift;
    }
  for my $param ($s->find(".//$xs:element")->get_nodelist) {
    my $attr = $param->getAttribute( 'name' );
    my $occurs = $param->getAttribute( 'minOccurs' );
    $service{operations}{$operation}{
      (defined $occurs and $occurs == 0)?'optional':'required'
      }{$attr}++;
    }
  }

$Data::Dumper::Indent = 1;
# $Data::Dumper::Varname = '__PACKAGE__';
my $newwsdl = Dumper \%service;
$newwsdl =~ s/\$VAR1 = {/\$__PACKAGE__ = {/;
$module =~ s/\$__PACKAGE__\s*=\s*{.*};/$newwsdl/s;
print $module;

sub getType {
  my $node = shift;

  return (undef, undef) unless $node;

  if (my $type = $node->getAttribute('type')) {
    return ($type =~ /:(\S+)/, $node->getAttribute('minOccurs'))
      if ($node->lookupNamespaceURI( $type =~ /(\S+):/ ) eq '');
    ($node) = $node->findnodes();
    return getType( $node );
  } else {
    return ('', $node->getAttribute('minOccurs'));
    }
      
  }

sub newmodule {
  my ($pkg, $wsdl) = @_;

  ($pkg) = $pkg =~ /([^\/]+)(\.pm|)$/;
  my $module = 'package AWS::' . $pkg;

  $module .= q|;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

our $__PACKAGE__ = {
  'wsdl' => '|;

  $module .= $wsdl;

  $module .= q|',
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
|;
  return $module;
  }

