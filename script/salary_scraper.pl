
use WWW::Mechanize;
use Web::Scraper;
use DBI;
use Encode;
use Data::Dumper;

my $driver = 'SQLite';
my $path_db = './database/salary_scraper.sqlite';

my $dbh = DBI -> connect("DBI:$driver:dbname=$path_db","","",{ RaiseError => 1 }) or die $DBI::errstr;

sub retrive_url{
    my $idx = $_[0];
    return "https://www.salary.com/tools/salary-calculator/search?keyword=developer&location=&page=$idx&selectedjobcodes=";
}

sub retrive_url_by_title{
    my $title = $_[0];
    return "https://www.salary.com/tools/salary-calculator/$title";
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

my $data = scraper {
    process '.sa-layout-2a-a > .sa-layout-section.border-top-none.sal-border-bottom > .sal-popluar-skills' ,'salaries[]' => scraper {
        process 'div[class="margin-bottom10 font-semibold sal-jobtitle"]',title => 'TEXT';
        process 'p[class="sal-jobdesc"]',description => 'TEXT';
        process 'div[class="margin-bottom10 font-semibold sal-jobtitle"] a',url => '@href';
    };
};

my $salary = scraper {
    process '.table-chart > tbody', 'tiles[]' => scraper {
        process '//tr[2]//td[2]', tile_10 => 'TEXT';
        process '//tr[2]//td[2]', tile_25 => 'TEXT';
        process '//tr[3]//td[2]', tile_50 => 'TEXT';
        process '//tr[4]//td[2]', tile_75 => 'TEXT';
        process '//tr[5]//td[2]', tile_90 => 'TEXT';
    };
};

for(my $i = int($idx); $i > 0; $i--){
    
    my $content = $data->scrape( URI->new(retrive_url($i)));


    for my $element (@{$content->{salaries}}){

        my @splited = split(',',$element->{url});

        my $unrel = substr(@splited[1],1,length(@splited[1])-2);

        my $tiles = $salary->scrape(URI -> new($unrel));

        for my $tile (@{$tiles->{tiles}}){

            my $insert = qq(
                INSERT INTO salary_scraper values(
                    "$element->{title}",
                    "location",
                    "$element->{description}",
                    "$tile->{tile_10}",
                    "$tile->{tile_25}",
                    "$tile->{tile_50}",
                    "$tile->{tile_75}",
                    "$tile->{tile_90}"
                )
            );

            my $exec_insert = $dbh -> do($insert) or die $DBI::errstr;

        }
    }


}







