package ZDB::FID;

use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

use base 'Exporter';
our @EXPORT_OK = qw(fid_name fid_library fid_isil is_fid fid);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# last update: 2019.03.22

my @collections = (
["FID-AAC-DE-188-144","FID Anglo-American Culture (FID Anglistik/Großbritannien- und Irlandstudien; FID Amerikastudien; FID Kanadastudien; FID Australien- und Neuseelandstudien)","Bibliothek des John F. Kennedy-Instituts der FU Berlin","DE-188-144"],
["FID-AAC-DE-7","FID Anglo-American Culture (FID Anglistik/Großbritannien- und Irlandstudien; FID Amerikastudien; FID Kanadastudien; FID Australien- und Neuseelandstudien)","SUB Göttingen;","DE-7"],
["FID-AFRIKA-DE-30","FID Afrikastudien","UB Frankfurt","DE-30"],
["FID-ALT-AY-DE-16","FID Altertumswissenschaften – Propylaeum","UB Heidelberg","DE-16"],
["FID-ALT-DE-12","FID Altertumswissenschaften – Propylaeum","BSB München","DE-12"],
["FID-ALT-KA-DE-16","FID Altertumswissenschaften – Propylaeum","UB Heidelberg","DE-16"],
["FID-ASIEN-DE-16","FID Asien – CrossAsia","UB Heidelberg","DE-16"],
["FID-ASIEN-DE-1a","FID Asien – CrossAsia","Staatsbibliothek zu Berlin","DE-1a"],
["FID-AVL-DE-30","FID Komparatistik - Allgemeine und Vergleichende Literaturwissenschaft","UB Frankfurt","DE-30"],
["FID-BBI-DE-23","FID Buch-, Bibliotheks- und Informations- wissenschaft","HAB Wolfenbüttel; UB Leipzig","DE-23"],
["FID-BENELUX-DE-6","FID Benelux / Low Countries Studies","Universitäts- und Landesbibliothek Münster","DE-6"],
["FID-BIFO-DE-29","FID Erziehungswissenschaft und Bildungsforschung","UB Uni Erlangen-Nürnberg","DE-29"],
["FID-BIFO-DE-Bs78","FID Erziehungswissenschaft und Bildungsforschung","Georg-Eckert-Institut - Leibniz-Institut für inter­nationale Schulbuchforschung, Braunschweig;","DE-Bs78"],
["FID-BIFO-DE-B478","FID Erziehungswissenschaft und Bildungsforschung","Bibliothek für Bildungsgeschichtliche Forschung (BBF) des DIPF; Informationszentrum Bildung (IZB) des DIPF","DE-B478"],
["FID-BIFO-HF-DE-11","FID Erziehungswissenschaft und Bildungsforschung","UB der HU Berlin","DE-11"],
["FID-BIODIV-DE-30","FID Bio­diversitäts­forschung","UB Frankfurt","DE-30"],
["FID-FINNUG-DE-7","FID Finnisch-ugri­sche / ura­lische Sprachen, Litera­turen und Kulturen","SUB Göttingen","DE-7"],
["FID-GEO-DE-7","FID Geowissenschaften der festen Erde","SUB Göttingen","DE-7"],
["FID-GEO-DE-B103","FID Geowissenschaften der festen Erde","Bibliothek Wissenschafts­park Albert Einstein","DE-B103"],
["FID-GER-DE-30","FID Germanistik","UB Frankfurt","DE-30"],
["FID-HIST-DE-12","FID Geschichtswissenschaft","BSB München","DE-12"],
["FID-HIST-DE-210","FID Geschichtswissenschaft","Bibliothek des Deutschen Museums","DE-210"],
["FID-INTRECHT-DE-1a","FID internationale und interdisziplinäre Rechtsforschung","Staatsbibliothek zu Berlin","DE-1a"],
["FID-JUDAICA-DE-30","FID Jüdische Studien","UB Frankfurt","DE-30"],
["FID-KARTEN-DE-1a","FID Kartographie und Geobasisdaten","Staatsbibliothek zu Berlin","DE-1a"],
["FID-KRIM-DE-21","FID Kriminologie","UB Tübingen und das Institut für Kriminologie\/Tübingen","DE-21"],
["FID-KUNST-DE-14","FID Kunst, Fotografie, Design - arthistoricum.net","SLUB Dresden","DE-14"],
["FID-KUNST-DE-16","FID Kunst, Fotografie, Design - arthistoricum.net","UB Heidelberg","DE-16"],
["FID-LATAM-DE-204","FID Lateinamerika, Karibik und Latino Studies","IAI Berlin","DE-204"],
["FID-LING-DE-30","FID Linguistik","UB Frankfurt","DE-30"],
["FID-MATHE-DE-7","FID Mathematik","SUB Göttingen","DE-7"],
["FID-MATHE-DE-89","FID Mathematik","TIB Hannover","DE-89"],
["FID-MEDIEN-DE-15","FID Medien-, Kommunikations- und Filmwissenschaften","UB Uni Leipzig","DE-15"],
["FID-MONTAN-DE-105","FID Montan (Bergbau und Hüttenwesen)","Universitätsbibliothek \"Georgius Agricola\" der TU Bergakademie Freiberg","DE-105"],
["FID-MOVE-DE-14","FID Mobilitäts- und Verkehrsforschung","SLUB Dresden; TIB Hannover","DE-14"],
["FID-MUS-DE-12","FID Musikwissenschaft","BSB München","DE-12"],
["FID-NAHOST-DE-3","FID Nahost-, Nordafrika- und Islamstudien","ULB Sachsen-Anhalt","DE-3"],
["FID-NORD-DE-8","FID Nordeuropa","UB Kiel","DE-8"],
["FID-OST-DE-12","FID Ost-, Ostmittel- und Südosteuropa","BSB München","DE-12"],
["FID-PHARM-DE-84","FID Pharmazie","UB Braunschweig","DE-84"],
["FID-POL-DE-46","FID Politikwissenschaft","SuUB Bremen; GESIS","DE-46"],
["FID-REWI-DE-21","FID Religionswissenschaft","UB Tübingen","DE-21"],
["FID-ROM-DE-18","FID Romanistik","SUB Hamburg","DE-18"],
["FID-ROM-DE-5","FID Romanistik","UB Uni Bonn","DE-5"],
["FID-SKA-DE-11","FID Sozial- und Kulturanthropologie","HU Berlin","DE-11"],
["FID-SLAW-DE-1a","FID Slawistik","Staatsbibliothek zu Berlin","DE-1a"],
["FID-SOZIO-DE-38","FID Soziologie","USB Köln; GESIS","DE-38"],
["FID-THEATER-DE-30","FID Darstellende Kunst","UB Frankfurt","DE-30"],
["FID-THEO-DE-21","FID Theologie","UB Tübingen","DE-21"],
["FID-ZENTRALASIEN-DE-7","FID Zentralasien - Autochthone Kulturen und Sprachen","SUB Göttingen","DE-7"],
["FID-PHILOS-DE-38","FID Philosopie","USB Köln","DE-38"],
["FID-SUEDASIEN-DE-16", "FID Südasien", "UB Heidelberg", "DE-16"],
);

sub fid_name {
    my $fid = shift;
    my ($name) = map { $_->[1] } grep { $_->[0] =~ m{^$fid$} } @collections;
    return $name;
}

sub fid_library {
    my $fid = shift;
    my ($name) = map { $_->[2] } grep { $_->[0] =~ m{^$fid$} } @collections;
    return $name;
}

sub fid_isil {
    my $fid = shift;
    my ($isil) = map { $_->[3] } grep { $_->[0] =~ m{^$fid$} } @collections;
    return $isil;
}

sub is_fid {
    my $fid = shift;
    my ($result)
        = map { $_->[0] } grep { $_->[0] =~ m{^$fid$} } @collections;
    return $result;
}

sub fid {
    return \@collections;
}

1;

__END__

=encoding utf-8

=head1 NAME

ZDB::FID - Get informations about Fachinformationsdienste (FID).

=head1 SYNOPSIS

    use ZDB::FID;
    my $name = fid_name('FID-THEO-DE-21'); 
    my $isil = fid_library('FID-THEO-DE-21');
    my $isil = fid_isil('FID-THEO-DE-21');
    my $exist = is_fid('FID-THEO-DE-21');

=head1 DESCRIPTION

Get informations about Fachinformationsdienste (FID).

=head1 METHODS

=head2 fid_name ($fid)

Get name for a FID.

=head2 fid_name ($fid)

Get library name for a FID.

=head2 fid_isil ($fid)

Get library ISIL for a FID.

=head2 is_fid($fid)

Check if FID exists.

=head2 fid()

Get all FIDs.

=head1 AUTHOR

Johann Rolschewski E<lt>jorol@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2016- Johann Rolschewski

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://www.zeitschriftendatenbank.de/suche/fachgebiete/#fid>, L<http://sigel.staatsbibliothek-berlin.de/fid-kennzeichen/>

=cut
