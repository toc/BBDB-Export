package BBDB::Export::MailAliases;
use strict;

our @ISA = qw(BBDB::Export);

our $VERSION = do { my @r=(q$Revision: 0.3 $=~/\d+/g);  sprintf "%d."."%03d"x$#r,@r };

use Data::Dumper;

#
#_* process_record
#

sub process_record
{
    my ( $self, $record ) = @_;

    return unless ( $record );
    return unless ( $record->{'full'} );
    return unless ( $record->{'net'}  );

    my $email = $record->{'net'}->[0];
    my $full = $record->{'full'};

    # determine nick
    my $nick;

    if    ( $record->{'nick'} )
    {
        # use the first nick in the list
        $nick = ( split( /,/, $record->{'nick'} ) )[0];
    }
    elsif ( $record->{'first'} && $record->{'last'} )
    {
        # build nick of first name and first char of last name
        $nick = $record->{'first'};
        $nick =~ s|\s.*$||;
        $nick .= substr( $record->{'last'}, 0, 1 );
    }
    elsif ( $record->{'last'} )
    {
        # use last name for nick
        $nick = $record->{'last'}
    }
    elsif ( $record->{'first'} )
    {
        # use first name for nick
        $nick = $record->{'first'};
    }

    # acceptable characters
    $nick =~ tr/a-zA-Z//cd;

    # lower case the nick
    $nick = lc( $nick );

    return qq(alias $nick "$full" <$email>\n);
}

#
#_* post_processing
#

sub post_processing
{
    my ( $self, $output ) = @_;

    return unless $output;

    my $outfile = $self->{'data'}->{'output_file'};
    return unless $outfile;

    open ( OUT, ">$outfile" ) or die "Unable to create $outfile";
    print OUT $output;
    close OUT;

    $self->info( "Exported mail_aliases data to $outfile" );
}

1;


