package BBDB::Export::LDAP;
use strict;

use BBDB::Export::LDIF;

our @ISA = qw(BBDB::Export);

our $VERSION = do { my @r=(q$Revision: 0.1 $=~/\d+/g);  sprintf "%d."."%03d"x$#r,@r };

use Data::Dumper;


#
#_* process_record
#

sub process_record
{
    my ( $self, $record ) = @_;

    my ( $text, $data ) = BBDB::Export::LDIF::process_record( $self, $record );

    my $tmpfile = $self->{'data'}->{'output_file'};
    return unless $tmpfile;

    my $dc = $self->{'data'}->{'dc'};
    return unless $dc;

    open ( OUT, ">$tmpfile" ) or die "Unable to create temp file $tmpfile";

    print OUT $text;

    close OUT;

    my $dn = $data->{'dn'};

    my $ldappass = $self->{'data'}->{'ldappass'};
    unless ( $ldappass )
    {
        $self->error( "ldappass not specified" );
        die;
    }

    $self->info( "Deleting dn: $dn" ) if $self->{'data'}->{'verbose'};
    $self->run_command( qq(ldapdelete -x -w $ldappass -D "cn=Manager,$dc" "$dn"), 1 );

    $self->info( "Adding dn: $dn" ) if $self->{'data'}->{'verbose'};
    my $add_cmd = qq(ldapadd -x -w $ldappass -D "cn=Manager,$dc" -f $tmpfile);
    $self->run_command( $add_cmd );

}

#
#_* post_processing
#

sub post_processing
{
    my ( $self, $output ) = @_;
    return 1;
}



1;


