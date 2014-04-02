use Test::More tests => 1;

BEGIN {
use_ok( 'AWS' );
}

diag( "Testing AWS $AWS::VERSION" );
