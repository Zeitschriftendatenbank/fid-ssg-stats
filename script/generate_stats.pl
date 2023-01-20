#!/usr/bin/env perl

use utf8;
use v5.12;
use strict;
use autodie;
use warnings;
use warnings  qw(FATAL utf8);
use open      qw(:std :utf8);
use charnames qw(:full :short);

use lib './lib';

use Catmandu;
use Catmandu::Exporter::XLSX;
use Catmandu::Exporter::Table;
use DDP;
use Getopt::Long 'HelpMessage';
use IO::Prompt::Tiny qw(prompt);
use List::Util       qw(uniq);
use MongoDB;
use Path::Tiny;
use Time::Piece;
use ZDB::FID qw(:all);
use ZDB::ILL qw(is_ill);
use ZDB::SSG qw(:all);

GetOptions(
    'year|y=i' => \(my $year = year_now()),
    'help|h'   => sub {HelpMessage(0)},
) or HelpMessage(1);

# get a MongoDB database handle
# my $dbh = _build_dbh();

# create dir for statistics of that year
# my $dir = create_dir($year);

say "Generate statistis for year $year...";

# create FID statistics
say 'Generate FID statistics...';
# stats_fid($dbh, $dir);

# create SSG statistics
say 'Generate SSG statistics...';
# stats_ssg($dbh, $dir);

# create docsify site structure
say 'Generate MD files...';
generate_site_structure();

say 'Done.';

sub _build_dbh {
    my $client = MongoDB::MongoClient->new(
        host          => 'mongodb://localhost:27017',
        query_timeout => 99999,
    )->get_database('zdb')->get_collection('data');
    return $client;
}

sub create_dir {
    my $year = shift;
    my $dir  = path("../data/$year");
    if ($dir->exists) {
        my $answer = prompt(
            "Directory already exists. Should it be overwritten? (Y/n)", "n");
        if ($answer eq 'Y') {
            $dir->remove_tree;
            $dir = path("../data/$year")->mkdir;
        }
        else {
            exit "Won't overwrite existing directory.";
        }
    }
    else {
        path("../data/$year")->mkdir;
    }
    return $dir;
}

sub generate_markdown_file {
    my ($year, $table_fid, $table_ssg) = @_;
    my $markdown = qq{# Statistiken $year

## FID

$table_fid

## SSG

$table_ssg
    };

    my $create_file = path("../$year.md")->spew_utf8($markdown);
    return $create_file;
}

sub generate_markdown_table {
    my ($type, $dir) = @_;
    my @table;
    foreach my $file_path (sort my @dirs
        = path($dir, $type)->children(qr/\.xlsx\z/))
    {
        my $file_name   = path($file_path)->basename('.xlsx');
        my $description = get_description($type, $file_name);
        $description->{Download}
            = '[![Download](./vendor/icons/download.svg)]('
            . set_download_path($file_path) . ')';
        push(@table, $description);
    }
    my $exporter = Catmandu::Exporter::Table->new(
        file   => \my $table,
        fields => 'Kennzeichen,Name,Einrichtung,Download'
    );
    $exporter->add_many(\@table);
    $exporter->commit;
    return $table;
}

sub generate_sidebar {
    my @docs
        = sort map {'* [' . get_year_from_path($_) . '](' . set_root_path($_) . ')'}
        path('../')->children(qr/\d{4}\.md/);
    unshift @docs, '* [Home](./home.md)';
    my $markdown    = join "\n", @docs;
    my $create_file = path("../_sidebar.md")->spew_utf8($markdown);
    return $create_file;
}

sub generate_site_structure {
    my $dir = path('../data');

    foreach my $subdir ($dir->children) {
        my $year      = get_year_from_path($subdir);
        my $fid_table = generate_markdown_table('fid', $subdir);
        my $ssg_table = generate_markdown_table('ssg', $subdir);
        my $doc       = generate_markdown_file($year, $fid_table, $ssg_table);
    }
    my $sidebar = generate_sidebar();

}

sub get_description {
    my ($type, $file_name) = @_;
    if ($type eq 'fid') {
        my $fid_name = fid_name($file_name);
        my $fid_isil = fid_isil($file_name);
        return {
            Kennzeichen => $file_name,
            Name        => $fid_name,
            Einrichtung => $fid_isil
        };
    }
    elsif ($type eq 'ssg') {
        my ($ssg_nr, $ssg_isils) = split /\_/, $file_name;
        $ssg_isils = join '; ', split /\+/, $ssg_isils;
        my $ssg_name = ssg_name($ssg_nr);
        return {
            Kennzeichen => $ssg_nr,
            Name        => $ssg_name,
            Einrichtung => $ssg_isils
        };
    }
    else {
        return;
    }
}

sub get_columns {
    my $columns
        = 'ZDBDID,Datenträger,Erscheinungsform,Titel,Verleger,Verlagsort,Sprache,Erscheinungsland,ISSN,DDC,SSG,Unterreihe,Parallelausgaben(Formate),Parallelausgaben(Sprachen),Beilagen,Nachfolger,Vorgänger,Erscheinungsverlauf,URL,Kostenfrei,SSG-Bibliothek,Laufend,Unikal,Anzahl-FL-Bibliotheken,FL-Bibliotheken';
    return $columns;
}

sub get_fields {
    my $fields
        = 'dc_identifier,dc_format,zdb_codes,dc_title,dc_publisher,rda_placeOfPublication,dc_language,dcterms_spatial,bibo_issn,dc_subject,zdb_ssg,marc_nameOfPart,dcterms_isFormatOf,dcterms_hasVersion,dcterms_hasPart,rda_succeededBy,rda_precededBy,dc_coverage,foaf_isPrimaryTopicOf,zdb_kfr,ssg,current,uniq,all_nr,all';
    return $fields;
}

sub get_year_from_path {
    my $path      = shift;
    my $canonpath = $path->canonpath;
    my ($year)    = $canonpath =~ m/\/(\d+)(\.md)?$/;
    return $year;
}

sub process_fid_holdings {
    my ($holdings, $isil) = @_;

    # only isil of libraries with current holdings
    my @all = uniq map {$_->{zdb_isil}} grep {
               exists $_->{zdb_isil}
            && exists $_->{dc_coverage}
            && $_->{dc_coverage} =~ m/-\s*$/
    } @{$holdings};
    my $result = {};
    my @fid    = uniq grep {$_ =~ m/^($isil)$/} @all;
    $result->{ssg}     = scalar @fid > 0 ? join(',', @fid) : '';
    $result->{current} = scalar @fid > 0 ? 'x'             : '';
    my @ill = uniq grep {$_ !~ m/^($isil)$/ && is_ill($_)} @all;
    $result->{uniq}
        = $result->{current} eq 'x' && scalar @ill == 0 ? 'x' : '';

    # $result->{singular}
    #     = $result->{current} eq 'x' && scalar @ill <= 3 ? 'x' : '';
    $result->{all}    = join ';', @ill;
    $result->{all_nr} = scalar @ill;
    return $result;
}

sub process_ssg_holdings {
    my ($holdings, $sigel) = @_;

    # only sigel of libraries with current holdings
    my @all = uniq map {$_->{zdb_sigel}} grep {
               exists $_->{zdb_sigel}
            && exists $_->{dc_coverage}
            && $_->{dc_coverage} =~ m/-\s*$/
    } @{$holdings};
    my $result = {};
    my @ssg    = uniq grep {$_ =~ m{^($sigel)$}} @all;
    $result->{ssg}     = scalar @ssg > 0 ? join(',', @ssg) : '';
    $result->{current} = scalar @ssg > 0 ? 'x'             : '';
    my @ill = uniq grep {$_ !~ m{^($sigel)$} && is_ill($_)} @all;
    $result->{uniq}
        = $result->{current} eq 'x' && scalar @ill == 0 ? 'x' : '';
    $result->{singular}
        = $result->{current} eq 'x' && scalar @ill <= 3 ? 'x' : '';
    $result->{all}    = join ';', @ill;
    $result->{all_nr} = scalar @ill;
    return $result;
}

sub set_root_path {
    my $path      = shift;
    my $canonpath = $path->canonpath;
    $canonpath =~ s/^\.\./\./;
    return $canonpath;
}

sub set_download_path {
    my $path      = shift;
    my $canonpath = $path->canonpath;
    $canonpath =~ s|^\.\.|https://zeitschriftendatenbank.github.io/fid-ssg-stats|;
    return $canonpath;
}

sub stats_fid {
    my ($dbh, $dir) = @_;

    $dir = path($dir, 'fid')->mkdir;

    foreach my $fid (@{fid()}) {
        my $code = $fid->[0];
        my $isil = $fid->[3];

        say "\t$code";
        my $fixer = Catmandu::Fix->new(
            fixes => ['../share/resource_export_tabular.fix']);

        # Get a MongoDB::Cursor for a query
        my $cursor = $dbh->find({zdb_ssg => $code});

        if ($cursor->has_next) {
            my $exporter = Catmandu::Exporter::XLSX->new(
                file    => path($dir, $code . '.xlsx')->canonpath,
                fields  => get_fields(),
                columns => get_columns(),
                header  => 1
            );
            my $rec_nr = 0;
            while (my $record = $cursor->next) {
                $rec_nr++;
                $fixer->fix($record);

                if (my $holdings
                    = process_fid_holdings($record->{holdings}, $isil))
                {
                    @{$record}{keys %{$holdings}} = values %{$holdings};
                    $exporter->add($record);
                }
                else {
                    warn "no holdings found for $record->{_id}";
                }
            }
            $exporter->commit;
        }
        else {
            next;
        }
    }
}

sub stats_ssg {
    my ($dbh, $dir) = @_;

    $dir = path($dir, 'ssg')->mkdir;

    foreach my $ssg (@{ssg()}) {
        my $code  = $ssg->[0];
        my $sigel = $ssg->[2];

        say "\t$code";
        my $fixer = Catmandu::Fix->new(
            fixes => ['../share/resource_export_tabular.fix']);

        # Get a MongoDB::Cursor for a query
        my $cursor = $dbh->find({zdb_ssg => $code});

        if ($cursor->has_next) {
            my $exporter = Catmandu::Exporter::XLSX->new(
                file => path($dir,
                    $code . '_' . sigel2isil($sigel, '+') . '.xlsx')
                    ->canonpath,
                fields  => get_fields(),
                columns => get_columns(),
                header  => 1
            );
            my $rec_nr = 0;
            while (my $record = $cursor->next) {
                $rec_nr++;
                $fixer->fix($record);

                if (my $holdings
                    = process_ssg_holdings($record->{holdings}, $sigel))
                {
                    @{$record}{keys %{$holdings}} = values %{$holdings};
                    $exporter->add($record);
                }
                else {
                    warn "no holdings found for $record->{_id}";
                }
            }
            $exporter->commit;
        }
        else {
            next;
        }
    }
}

sub year_now {
    my $localtime = localtime;
    return $localtime->year;
}

sub sigel2isil {
    my ($sigel, $delimiter) = @_;
    $sigel = join $delimiter,
        map {my $tmp = 'DE-' . $_; $tmp;}
        map {(my $tmp = $_) =~ s/\*/%2A/g;  $tmp}
        map {(my $tmp = $_) =~ s/[\.\s]//g; $tmp}
        map {(my $tmp = $_) =~ s/\//-/;     $tmp} split '\|', $sigel;
    return $sigel;
}

=head1 NAME

generate_stats.pl - generate journal statistics for FID and SSG from ZDB

=head1 SYNOPSIS

  --year,-y       Year (defaults to current year)
  --help,-h       Print this help message 

=head1 VERSION

0.01

=head1 COPYRIGHT

Copyright 2023- Johann Rolschewski
