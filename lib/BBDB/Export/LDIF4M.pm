package BBDB::Export::LDIF4M;
#
# BBDB::Export::LDIF4M
#  Author: Toshiaki Tanaka <Tanaka.Toshiaki@toshiba-sol.co.jp>
#   LDIF for Mozilla.  Copy LDIF.pm and modify it for Mozilla Thunderbird 2.x.
#
use strict;

our @ISA = qw(BBDB::Export);

our $VERSION = do { my @r=(q$Revision: 0.5 $=~/\d+/g);  sprintf "%d."."%03d"x$#r,@r };

use Data::Dumper;

#
#_* get_record_hash
#
sub get_record_hash
{
    my ( $self, $record ) = @_;

    # call get_record_hash from BBDB::Export
    $record = $self->SUPER::get_record_hash( $record );

    unless ( $record->{'first'} || $record->{'last'} )
    {
        $self->error( "No first or last name for record" );
        return undef;
    }

    # add some custom fields to the hash
    $record->{'dn'} = lc( "cn=$record->{'full'}, ou=addressbook, $self->{'data'}->{'dc'}" );

    my @objectClass = qw( top person organizationalPerson inetOrgPerson mozillaAbPersonAlpha);
    $record->{'objectClass'} = \@objectClass;

    $record->{'cn'} = $record->{'full'};
    $record->{'givenName'} = $record->{'last'} || 'N/A';
    $record->{'sn'} = $record->{'first'};
    $record->{'ou'} = "addressbook";

    if ( $record->{'net'} ) {
      $record->{'mail'} = ( @{ $record->{'net'} } )[0];
      if ( $#{ $record->{'net'}} > 1 ) {
	$record->{'mozillaSecondEmail'} = ( @{ $record->{'net'} } )[1];
      }
    }
    $record->{'mozillaUseHtmlMail'} = 'FALSE';
    $record->{'street'} = $record->{'street'};
    $record->{'l'} = $record->{'city'};
    $record->{'st'} = $record->{'state'};
    $record->{'postalCode'} = $record->{'zip'};

    # Phone
    if ( $record->{'phone'} )
    {
        $record->{'telephoneNumber'}          = $record->{'phone'}->{'Office'};
        $record->{'homePhone'}                = $record->{'phone'}->{'Home'};
        $record->{'mobile'}                   = $record->{'phone'}->{'HP'};
        $record->{'pager'}                    = $record->{'phone'}->{'pager'};
        $record->{'facsimileTelephoneNumber'} = $record->{'phone'}->{'fax'};
    }


    # title
    my @title;
    if ( $record->{'title'} )
    {
        push @title, $record->{'title'};
    }
    if ( $record->{'group'} )
    {
        push @title, $record->{'group'};
    }
    if ( $record->{'company'} )
    {
        push @title, $record->{'company'};
    }
    if ( $title[0] )
    {
        $record->{'title'} = join ( " - ", @title );
    }

    # nickname
    $record->{'mozillaNickname'} = $record->{'aka'}->[0];

    # description
    $record->{'description'} = $record->{'notes'};

    return $record;

}

#
#_* process_record
#

sub process_record
{
    my ( $self, $record ) = @_;
    my ( $data, $return );

    if ( $record->{ 'sn' } =~ m/^[△▲]/ ) {
      return ( $return, $data );
    }
    # start of record
    for my $field ( qw(
                       dn objectClass cn givenName sn  ou mail mozillaSecondEmail
                       mozillaNickname mozillaUseHtmlMail street l st postalCode
                       telephoneNumber homePhone mobile pager facsimileTelephoneNumber
                       title description
                      ) )
    {
        next unless $record->{ $field };
        if ( ref $record->{ $field } eq "ARRAY" )
        {
            for my $index ( 0 .. $#{ $record->{ $field } } )
            {
                $return .= $self->format_field( $field, $record->{ $field }->[$index] );
            }
        }
        else
        {
            $return .= $self->format_field( $field, $record->{ $field } );
        }
    }

    # jpegPhoto
    if ( $record->{'face'} )
    {
        $return .= "jpegPhoto:: ";
        $return .= $record->{'face'};
        $return .= "\n";
    }

    $return .= "\n\n";

    return ( $return, $data );

}

#
#_* post_processing
#
sub post_processing
{
    my ( $self, $output ) = @_;

    $self->info("Exporting to LDIF" );

    unless ( $output )
    {
        $self->error( "No text to export to LDIF" );
        return "";
    }

    my $outfile = $self->{'data'}->{'output_file'};
    unless ( $outfile && ! $self->{'data'}->{'quiet'} )
    {
        $self->error( "No output_file defined" );
        return "";
    }

    open ( OUT, ">$outfile" ) or die "Unable to create $outfile";
    print OUT $output;
    close OUT;

    $self->info( "Exported LDIF data to $outfile" );

    return $output;
}

1;


