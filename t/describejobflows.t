use Test::More;
use LWP;
use URI;
use URI::QueryParam;
use DateTime;
use Digest::SHA qw(hmac_sha256_base64);
use AWS;

my $time = time;
my $key = "AWSKEY";
my $secret = "AWSTEST";

my $a=AWS->new(aws_account=> $key, aws_secret=>$secret,)->EMR;
$a->request->date( $time );
$a->DescribeJobFlows->sign;

my $b = MockDescribeJobFlows( $key, $secret, $time );

is($a->uri->query_param('Signature'), $b->query_param('Signature'), 'Signature matches');

done_testing();

sub MockDescribeJobFlows {
  my ($key, $secret, $time) = @_;

  my $job = URI->new('https://elasticmapreduce.amazonaws.com');

  my %params = (
    Operation => 'DescribeJobFlows',
    # ContentType => 'JSON',
    AWSAccessKeyId => $key,
    SignatureVersion => 2,
    SignatureMethod => 'HmacSHA256',
    Timestamp => DateTime->from_epoch( epoch => $time ) . '.000Z',
    );

  for my $key (sort keys %params) {
    $job->query_param( $key, $params{ $key });
    }

  my $final = $job->query;
  $final =~ s/\+/\%20/g;
  $final = "GET\n" . $job->authority . "\n\/\n" . $final;
  $job->query_param( Signature =>
    hmac_sha256_base64( $final, $secret ) . '=' );

  return $job;
  }



