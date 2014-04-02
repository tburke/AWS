use Test::More;
use AWS;

my $key = "AWSKEY";
my $secret = "AWSTEST";
my $time = 1269978353;


$s3=AWS->new(aws_account=>$key, aws_secret=>$secret,)->S3;
$s3->request->date( $time );
$s3->sign;

is($s3->request->header('authorization'),
  'AWS AKIAJC2STRZAAC3FWSTA:yqZN34IDIZuZjQtiwYfjKGshvXg=',
  'Signature match');

done_testing();

