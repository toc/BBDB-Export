package BBDB::Export::vCard;
use strict;

our @ISA = qw(BBDB::Export);

our $VERSION = do { my @r=(q$Revision: 1.1 $=~/\d+/g);  sprintf "%d."."%03d"x$#r,@r };

use Data::Dumper;

#
#_* process_record
#

sub process_record
{
    my ( $self, $record ) = @_;

    my $return = "";

    $return .= "begin:vcard\n";
    $return .= "version:3.0\n";

    return ( $return );

}

#
#_* post_processing
#

# no post processing necessary for vcard since there is one entry per
# file.
sub post_processing
{
    my ( $self, $output ) = @_;
    return $output;
}

1;


