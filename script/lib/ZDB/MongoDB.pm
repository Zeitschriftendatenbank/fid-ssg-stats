package ZDB::MongoDB;

use Moo;
use MongoDB;

use DDP;

has 'host' => ( is => 'ro', default => sub {'mongodb://localhost:27017'}, );

has 'database' => ( is => 'ro', default => sub {'zdb'}, );

has 'collection' => ( is => 'ro', default => sub {'data'}, );

has 'client' => ( is => 'ro', lazy => 1, builder => '_build_client' );

sub _build_client {
    my $self   = shift;
    my $client = MongoDB::MongoClient->new(
        host          => $self->host,
        query_timeout => 99999,
    )->get_database( $self->database )
        ->get_collection( $self->collection );
    return $client;
}

sub get_record_by_zdbid {
    my ( $self, $zdbid ) = @_;
    my $hit = $self->client->find_one( { _id => $zdbid } );
    return $hit;
}

sub get_record_by_idn {
    my ( $self, $idn ) = @_;
    my $hit = $self->client->find_one( { zdb_idn => $idn } );
    return $hit;
}

sub get_parallel_editions_from_record {
    my ( $self, $zdbid, $format ) = @_;
    my $record = $self->client->find_one( { _id => $zdbid },
        { dct_isFormatOf => 1 } );
    my @parallel_editions;
    if ($format) {
        @parallel_editions = map { $_->[0] }
            grep { $_->[2] =~ m/$format/ } @{ $record->{dct_isFormatOf} };
    }
    else {
        @parallel_editions = map { $_->[0] } @{ $record->{dct_isFormatOf} };
    }
    return @parallel_editions;
}

sub get_holdings_from_record {
    my ( $self, $zdbid, $isil ) = @_;
    my $record
        = $self->client->find_one( { _id => $zdbid }, { holdings => 1 } );
    my @holdings;
    if ($isil) {
        @holdings = grep { $_->{zdb_isil} eq $isil } @{ $record->{holdings} };
    }
    else {
        @holdings = @{ $record->{holdings} };
    }
    return @holdings;
}

sub find_records_by_issn {
    my ( $self, $issn ) = @_;
    my $hits = $self->client->find(
        {
            '$or' => [
                { 'bibo_issn'        => $issn },
                { 'bibo_eissn'       => $issn },
                { 'zdb_parallelIssn' => $issn }
            ]
        }
    );
    return $hits;
}

sub find_records_by_query {
    my ( $self, $query ) = @_;
    my $hits = $self->client->find($query);
    return $hits;
}

1;
