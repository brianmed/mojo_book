#!perl
use Mojo::Base -strict;

use Mojo::IOLoop;
use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new;
my $addr = shift // die("Please pass in an IP");

# Get latitude, longitude
my $ip = $ua->get(sprintf("http://ip-api.com/json/%s", $addr));

# Setup weather query
my $query = sprintf(
    "lat=%s&lon=%s&unit=0&lg=english&FcstType=json",
    $ip->res->json->{lat},
    $ip->res->json->{lon}
);
my $url = sprintf("http://forecast.weather.gov/MapClick.php?%s", $query);
my $weather = $ua->get($url);

# Talk about the weather
my $j = $weather->res->json;
say(sprintf(
    "$addr: %s: %s: %s", 
    $j->{location}{areaDescription},
    $j->{time}{startPeriodName}[0],
    $j->{data}{text}[0]
));
