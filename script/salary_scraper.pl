use strict;
use WWW::Mechanize;
use Web::Scraper;
use DBI;
use Encode;

my $driver = 'SQLite';
my $path_db = './database/salary_scraper.sqlite';

my $dbh = DBI -> connect("DBI:$driver:dbname=$path_db","","",{ RaiseError => 1 }) or die $DBI::errstr;
=a
my $table_create = qq( CREATE TABLE salary_scraper (
    title TEXT,
    location TEXT,
    description TEXT,
    tile_10 TEXT,
    tile_25 TEXT,
    tile_50 TEXT,
    tile_75 TEXT,
    tile_90 TEXT
)
);

my $exec_create_table = $dbh -> do($table_create) or die $DBI::errstr; 
=cut
my $q = "developer";
my $url = "https://www.salary.com/tools/salary-calculator/search?keyword=developer&location=&page=1&selectedjobcodes=";

my $start = scraper {
    # Parse all TDs inside 'table[width="100%]"', store them into
    # an array 'authors'.  We embed other scrapers for each TD.
    process 'nav[id="cityjobResultPagination"] ul[class="pagination"] li', "all[]" => scraper {
      process "a", link => '@href';
    };
};


my $res = $start->scrape( URI->new($url) );

my $last_index = pop @{$res->{all}};

my $idx = substr "$last_index->{link}",index("$last_index->{link}","page=")+5,2;

print $idx;

for my $uri (@{$res->{all}}) {
    # output is like:
    # Andy Adler      http://search.cpan.org/~aadler/
    # Aaron K Dancygier       http://search.cpan.org/~aakd/
    # Aamer Akhter    http://search.cpan.org/~aakhter/
    #print Encode::encode("utf8", "$uri->{link}\n");
}




