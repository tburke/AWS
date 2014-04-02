use Test::More;
use AWS;

my $time = 1270003340;
my $key = "AWSKEY";
my $secret = "AWSTEST";

my $a=AWS->new(aws_account=> $key, aws_secret=>$secret,)->EC2;
$a->request->date( $time );
$a->DescribeKeyPairs->sign;

is($a->uri->query_param('Signature'), 'tyku7g9x/AEeeBHjbo9lEo6KKU+ZVApct55Eqt0O3H8=', 'Signature matches');

done_testing();

