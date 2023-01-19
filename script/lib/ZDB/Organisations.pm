package ZDB::Organisations;

use strict;
use warnings;
use v5.14;

our $VERSION = '0.01';

use Catmandu::Store::MongoDB;
use Config::Tiny;
use File::Share qw(dist_file);
use Moo;
use ZDB;

has 'config' => (
    is      => 'ro',
    default => sub {
        Config::Tiny->read( dist_file( 'ZDB', 'organisations.ini' ), 'utf8' );
    }
);
has 'dbh' => (
    is      => 'lazy',
    builder => sub {
        Catmandu::Store::MongoDB->new(
            host          => $_[0]->{config}->{mongodb}->{host},
            query_timeout => $_[0]->{config}->{mongodb}->{query_timeout},
            database_name => $_[0]->{config}->{mongodb}->{database_name}
        );
    }
);

sub isil {
    my ( $self, $isil ) = @_;
    my $hits = $self->dbh->bag( $self->{config}->{mongodb}->{collection} )
        ->search( query => { isil => $isil } );
    if ( $hits->total == 1 ) {
        return $hits->first;
    }
    return;
}

sub sigel {
    my ( $self, $sigel ) = @_;
    my $hits = $self->dbh->bag( $self->{config}->{mongodb}->{collection} )
        ->search( query => { sigel => $sigel } );
    if ( $hits->total == 1 ) {
        return $hits->first;
    }
    return;
}

sub ill {
    my ( $self, $isil ) = @_;
    my $hits = $self->dbh->bag( $self->{config}->{mongodb}->{collection} )
        ->search( query => { isil => $isil } );
    if ( $hits->total == 1 ) {
        return $hits->first->{ill};
    }
    return;
}

1;

=encoding utf-8

=head1 NAME

ZDB::Organisations - Tools for ZDB organisations.

=head1 SYNOPSIS

  use ZDB::Organisations;

=head1 DESCRIPTION

ZDB::Organisations provides tools for ZDB organisations.

=head1 METHODS

=head2 isil( $isil )

Get metadata for an specific library identified by ISIL.

=head2 sigel( $sigel )

Get metadata for an specific library identified by Sigel.

=head2 ill( $isil )

Returns the Inter Library Loan (ILL) codes for an library.

=head1 AUTHOR

Johann Rolschewski E<lt>jorol@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2016- Johann Rolschewski

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
