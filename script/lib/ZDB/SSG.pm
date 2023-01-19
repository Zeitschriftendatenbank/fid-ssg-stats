package ZDB::SSG;

use strict;
use warnings;
use utf8;
our $VERSION = '0.01';

use base 'Exporter';
our @EXPORT_OK = qw(ssg_name ssg_sigel is_ssg ssg);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my @collections = (
    [ "0", "Allgemeine und vergleichende Religionswissenschaft", "21" ],
    [ "1", "Theologie",                                          "21" ],
    [ "2", "Rechtswissenschaft",                                 "1|1a" ],
    [ "2,1", "Kriminologie und Kriminalistik",     "21|21/110" ],
    [ "3,1", "Volkswirtschaft und Weltwirtschaft", "206|206 H" ],
    [ "3,2", "Betriebswirtschaft",                 "206|206 H" ],
    [ "3,4", "Sozialwissenschaften",               "38" ],
    [ "3,5", "Kommunikations- und Medienwissenschaften. Publizistik", "15" ],
    [ "3,6", "Politik, Friedensforschung",                            "18" ],
    [   "3,61",
        "Parteien und Gewerkschaften aus Europa und Nordamerika (nicht-konventionelle Literatur)",
        "Bo 133"
    ],
    [ "3,7", "Verwaltungswissenschaften", "18" ],
    [   "3,8", "Kommunalwissenschaften (deutschsprachiger Bereich)",
        "109/720"
    ],
    [ "4",    "Medizin",                                     "38 M" ],
    [ "5,1",  "Philosophie",                                 "29" ],
    [ "5,2",  "Psychologie",                                 "291" ],
    [ "5,21", "Parapsychologie",                             "25/122" ],
    [ "5,3",  "Bildungsforschung",                           "29" ],
    [ "5,31", "Bildungsgeschichte (deutschsprachiger Raum)", "B 478" ],
    [ "6,11", "Vor- und Frühgeschichte",                    "12" ],
    [   "6,12",
        "Klassische Altertumswissenschaft einschl. Alte Geschichte, Mittel- und Neulateinische Philologie",
        "12"
    ],
    [ "6,14", "Klassische Archäologie",             "16" ],
    [ "6,15", "Byzanz",                              "12" ],
    [ "6,16", "Neuzeitliches Griechenland",          "12" ],
    [ "6,21", "Ägyptologie",                        "16" ],
    [ "6,22", "Alter Orient",                        "21" ],
    [ "6,23", "Vorderer Orient einschl. Nordafrika", "3/1" ],
    [ "6,24", "Südasien",                           "16/77" ],
    [ "6,25", "Ost- und Südostasien",               "1|1a" ],
    [   "6,26",
        "Altaische und paläoasiatische Sprachen, Literaturen und Kulturen",
        7
    ],
    [ "6,31", "Afrika südlich der Sahara",                   "30" ],
    [ "6,32", "Ozeanien",                                     "30" ],
    [ "6,33", "Indigene Völker Nordamerikas und der Arktis", "18" ],
    [   "7,11",
        "Allgemeine und vergleichende Sprachwissenschaft, Allgemeine Linguistik",
        "30"
    ],
    [ "7,12", "Allgemeine und vergleichende Literaturwissenschaft", "30" ],
    [ "7,20", "Germanistik, Deutsche Sprache und Literatur",        "30" ],
    [ "7,22", "Skandinavien",                                       "8|830" ],
    [ "7,23", "Benelux",                                            "6|6/N" ],
    [ "7,23", "Benelux",                                            "38" ],
    [ "7,24", "Anglistik, Allgemeines",                             "7" ],
    [ "7,25", "Großbritannien und Irland",                         "7" ],
    [ "7,26", "Nordamerika",                                        "7" ],
    [ "7,261", "Nordamerikanische Zeitungen",         "188/144" ],
    [ "7,27",  "Keltologie",                          "7" ],
    [ "7,29",  "Australien, Neuseeland",              "7" ],
    [ "7,30",  "Romanistik, Allgemeines",             "5" ],
    [ "7,31",  "Französische Sprache und Literatur", "5" ],
    [ "7,32",  "Italienische Sprache und Literatur",  "5" ],
    [ "7,34",  "Spanien, Portugal",                   "18" ],
    [ "7,36",  "Ibero-Amerika",                       "204" ],
    [ "7,38",  "Rumänische Sprache und Literatur",   "12" ],
    [ "7,39",  "Slawistik",                           "1|1a" ],
    [ "7,41",  "Ost-, Ostmittel- und Südosteuropa",  "12" ],
    [ "7,43",  "Albanische Sprache und Literatur",    "12" ],
    [ "7,44",  "Baltische Länder",                   "9|9/34" ],
    [ "7,50",  "Finno-Ugristik",                      "7" ],
    [ "7,51",  "Finnland",                            "7" ],
    [ "7,52",  "Ungarn",                              "7" ],
    [ "7,53",  "Estnische Sprache und Literatur",     "7" ],
    [ "7,6",   "Israel",                              "30" ],
    [ "7,7",   "Judentum",                            "30" ],
    [ "8",     "Geschichte, Allgemeines",             "12" ],
    [ "8,1", "Geschichte Deutschlands, Österreichs und der Schweiz", "12" ],
    [ "8,2", "Geschichte Frankreichs und Italiens",                   "12" ],
    [   "8,3",
        "Nicht-konventionelle Materialien zur Zeitgeschichte aus dem deutschsprachigen Bereich",
        "24"
    ],
    [   "9,10",
        "Allgemeine Kunstwissenschaft, Mittlere und Neuere Kunstgeschichte bis 1945",
        "16"
    ],
    [ "9,11", "Zeitgenössische Kunst ab 1945",   "14|14/.*" ],
    [ "9,2",  "Musikwissenschaft",                "12" ],
    [ "9,3",  "Theater und Filmkunst",            "30" ],
    [ "10",   "Volks- und Völkerkunde",          "11|11/10|11/103|11/105" ],
    [ "11",   "Naturwissenschaften, Allgemeines", "7" ],
    [ "12",   "Biologie, Botanik, Zoologie",      "30" ],
    [ "13",    "Geologie, Mineralogie, Petrologie und Bodenkunde", "105" ],
    [ "13,1",  "Regionale Geologie",                               "Hv 112" ],
    [ "14",    "Geographie",                                       "7" ],
    [ "14,1",  "Veröffentlichungen zur Kartographie",             "1|1a" ],
    [ "15",    "Chemie",                                           "89" ],
    [ "15,3",  "Pharmazie",                                        "84" ],
    [ "16",    "Physik",                                           "89" ],
    [ "16,12", "Astronomie, Astrophysik, Weltraumforschung",       "7" ],
    [ "16,13", "Geophysik",                                        "7" ],
    [ "16,14", "Meteorologie",                                     "B 23" ],
    [ "16,15", "Ozeanographie",                                    "H 2" ],
    [ "17,1",  "Reine Mathematik",                                 "7" ],
    [ "17,2",  "Angewandte Mathematik",                            "89" ],
    [ "17,3",  "Geodäsie und Vermessungswesen",                   "89" ],
    [ "18",    "Informatik, Datenverarbeitung",                    "89" ],
    [ "19",    "Ingenieurwissenschaften, Technik",                 "89" ],
    [ "19,1",  "Bergbau, Markscheidekunde, Hüttenwesen",          "105" ],
    [ "19,2", "Technikgeschichte", "14|14/*" ],
    [ "20", "Architektur, Städtebau, Landesplanung, Raumordnung", "89" ],
    [   "20,1",
        "Nicht-konventionelle Materialien zu Städtebau, Landesplanung, Raumordnung aus dem deutschsprachigen Bereich",
        "109|720"
    ],
    [ "21",   "Agrarwissenschaften",                         "98" ],
    [ "21,3", "Küsten- und Hochseefischerei",               "18" ],
    [ "22",   "Veterinärmedizin, Allgemeine Parasitologie", "95" ],
    [ "23",   "Forstwissenschaft",                           "7" ],
    [ "24,1", "Informations-, Buch- und Bibliothekswesen",   "12" ],
    [   "24,2",
        "Hochschulwesen, Organisation der Wissenschaften und ihrer Einrichtungen",
        "11|11/87|11/97|11/103|11/105|11/131"
    ],
    [ "25",   "Universale wissenschaftliche Zeitschriften", "12" ],
    [ "26",   "Ausländische Zeitungen",                    "1|1a|1w" ],
    [ "27",   "Parlamentsschriften",                        "1|1a" ],
    [ "28,1", "Topographische Karten",                      "1|1a" ],
    [ "28,2", "Thematische Karten",                         "7" ],
    [ "28,3", "Seekarten",                                  "H 2" ],
    [ "28,4", "Meteorologische und klimatologische Karten", "B 23" ],
    [ "30",   "Schulbücher",                               "Bs 78" ],
    [ "31",   "Sportwissenschaft",                          "Kn 41" ],
);

sub ssg_sigel {
    my $ssg = shift;
    my @sigel = map { $_->[2] } grep { $_->[0] =~ m{^$ssg$} } @collections;
    return @sigel;
}

sub ssg_name {
    my $ssg = shift;
    my ($name) = map { $_->[1] } grep { $_->[0] =~ m{^$ssg$} } @collections;
    return $name;
}

sub is_ssg {
    my $ssg = shift;
    my ($valid_ssg)
        = map { $_->[0] } grep { $_->[0] =~ m{^$ssg$} } @collections;
    return $valid_ssg;
}

sub ssg {
    return \@collections;
}

1;

__END__

=encoding utf-8

=head1 NAME

ZDB::SSG - Get informations about Sondersammelgebiete (SSG).

=head1 SYNOPSIS

    use ZDB::SSG;
    my $name  = ssg_name('2,1'); 
    my $sigel = ssg_sigel('2,1');
    my $exist = is_ssg('2,1');


=head1 DESCRIPTION

Get informations about Sondersammelgebiete (SSG).

=head1 METHODS

=head2 ssg_sigel (<SSG-Nr>)

Get library Sigel for a SSG.

=head2 ssg_name (<SSG-Nr>)

Get name for a SSG.

=head2 is_ssg(<SSG-Nr>)

Check if SSG exists.

=head2 ssg()

Get all SSGs.

=head1 AUTHOR

Johann Rolschewski E<lt>jorol@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2016- Johann Rolschewski

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
