package AWS::SDB;

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.3');

use base qw(AWS::Base);

our $__PACKAGE__ = {
  'operations' => {
    'PutAttributes' => {
      'required' => {
        'Attribute' => 1,
        'DomainName' => 1,
        'ItemName' => 1
      },
      'optional' => {
        'Expected' => 1
      }
    },
    'DomainMetadata' => {
      'required' => {
        'DomainName' => 1
      }
    },
    'DeleteDomain' => {
      'required' => {
        'DomainName' => 1
      }
    },
    'CreateDomain' => {
      'required' => {
        'DomainName' => 1
      }
    },
    'ListDomains' => {
      'optional' => {
        'NextToken' => 1,
        'MaxNumberOfDomains' => 1
      }
    },
    'DeleteAttributes' => {
      'required' => {
        'DomainName' => 1,
        'ItemName' => 1
      },
      'optional' => {
        'Attribute' => 1,
        'Expected' => 1
      }
    },
    'Select' => {
      'required' => {
        'SelectExpression' => 1
      },
      'optional' => {
        'NextToken' => 1,
        'ConsistentRead' => 1
      }
    },
    'BatchPutAttributes' => {
      'required' => {
        'Item' => 1,
        'DomainName' => 1
      }
    },
    'GetAttributes' => {
      'required' => {
        'DomainName' => 1,
        'ItemName' => 1
      },
      'optional' => {
        'ConsistentRead' => 1,
        'AttributeName' => 1
      }
    }
  },
  'wsdl' => 'http://sdb.amazonaws.com/doc/2009-04-15/AmazonSimpleDB.wsdl',
  'version' => '2009-04-15',
  'endpoint' => 'https://sdb.amazonaws.com'
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
