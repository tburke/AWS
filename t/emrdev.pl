use AWS;
use DateTime;

my $dt = DateTime->now;

print "Start\n";

my $key = "AWSKEY";
my $secret = "AWSSECRET";
my $bucketname = 'dwdev';

my $a=AWS->new(aws_account=> $key, aws_secret=>$secret, 
  s3_bucket=>$bucketname, aws_keyname=>'wapopig')->EMR;

my $j = $a->job->HiveJob( Name => 'Dev Process ' . $dt->date,
    Args => [
    '-f', "s3://$bucketname/pig/dcgeocount.hive",
    '-d', 'DATE=' . $dt->date,
    '-d', 'DATEND=' . $dt->date(""),],
    );

$j->RunHiveScript( 'alter', '-e', 'alter table impressions recover partitions');

$j->start;

$j->EMRAddSteps;
$j->RunHiveScript( 'Another step', '-f', "s3://$bucketname/pig/dcgeocount.hive", );
$j->start;

$j->donewait;

print "Done\n";

