
use WWW::Mechanize;
use Web::Scraper;
use DBI;
use Encode;

my $driver = 'SQLite';
my $path_db = './database/salary_scraper.sqlite';

my $dbh = DBI -> connect("DBI:$driver:dbname=$path_db","","",{ RaiseError => 1 }) or die $DBI::errstr;

sub retrive_url{
    my $idx = $_[0];
    return "https://www.salary.com/tools/salary-calculator/search?keyword=developer&location=&page=$idx&selectedjobcodes=";
}
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
my $url = retrive_url(1);

my $start = scraper {
    process 'nav[id="cityjobResultPagination"] ul[class="pagination"] li', "all[]" => scraper {
      process "a", link => '@href';
    };
};


my $res = $start->scrape( URI->new($url) );

my $last_index = pop @{$res->{all}};

my $idx = substr "$last_index->{link}",index("$last_index->{link}","page=")+5,2;

print $idx;

my $data = scraper {
    process 'div[class="sa-layout-section"] div[class="sal-popluar-skills"]','salary[]' => scraper {
        process 'div[class="sal-jobtitle"]',title => 'TEXT';
        process 'p[class="sal-jobdesc"]',url => '@href';
    };
};

for(my $i = int($idx); $i > 0; $i--){
	my $content = $data->scrape(URI -> new(retrive_url($i)));
}




