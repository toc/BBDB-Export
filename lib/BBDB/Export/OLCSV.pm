package BBDB::Export::OLCSV;
#
# BBDB::Export::OLCSV
#  Author: Toshiaki Tanaka <Tanaka.Toshiaki@toshiba-sol.co.jp>
#   CSV for Outlook address list.  You can import BBDB -> Outlook.
#
use strict;

our @ISA = qw(BBDB::Export);

our $VERSION = do { my @r=(q$Revision: 0.5 $=~/\d+/g);  sprintf "%d."."%03d"x$#r,@r };

#use Text::CSV_XS;
  ## TODO: Text::CSV(_XS)では日本語がうまく扱えなかったので、現在はゴリ
  ##   ゴリのCSV作成ルーチンとなっている
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
    $record->{'givenName'} = $record->{'last'} || 'N/A';
    $record->{'sn'} = $record->{'first'};

    if ( $record->{'net'} ) {
      $record->{'mail'} = ( @{ $record->{'net'} } )[0];
      if ( $#{ $record->{'net'}} > 1 ) {
	$record->{'mail2'} = ( @{ $record->{'net'} } )[1];
      }
    }

    # Phone
    if ( $record->{'phone'} )
    {
        $record->{'telephoneNumber'} =
	  $record->{'phone'}->{'Office'} || $record->{'phone'}->{'work'};
        $record->{'homePhone'} =
	  $record->{'phone'}->{'Home'} || $record->{'phone'}->{'home'};
        $record->{'mobile'} =
	  $record->{'phone'}->{'HP'} || $record->{'phone'}->{'mobile'};
    }


    # nickname
    $record->{'cn'} = $record->{'aka'}->[0];
    # description
    $record->{'description'} = $record->{'notes'};
    # timestamps
    $record->{'created'} = $record->{'creation-date'};
    $record->{'updated'} = $record->{'timestamp'};

    return $record;
}

#
#_* process_record
#

sub process_record
{
    my ( $self, $record ) = @_;
    my ( $data, $return );
    my ( $csv , @columns, $col );

    if ( $record->{ 'sn' } =~ m/^[△▲]/ ) {
      return ( $return, $data );
    }

#    $self->info("Processing to CSV for Outlook." );

    # start of record
    $col = '';
    for my $field ( qw(
                       sn givenName
                       telephoneNumber homePhone mobile
                       description
		       cn mail cn mail2
		       created updated
                      ) )
    {
      if ( $record->{ $field } ) {
	$col .= '"' . $record->{ $field } . '"';
      } else {
	$col .= '';
      }
      $col .= ',';
    }

    $return = $col . "\n";

    return ( $return, $data );
}

#
#_* post_processing
#
sub post_processing
{
    my ( $self, $output ) = @_;
    my ( $csv , @columns );

    $self->info("Exporting to CSV for Outlook." );

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

    ###
    ### 一行目のみ \r\n であれば Outlook でインポート可能なようだ
    ###
    print OUT '"姓","名","会社電話","自宅電話","携帯電話","ﾒﾓ","電子ﾒｰﾙ表示名","電子ﾒｰﾙ ｱﾄﾞﾚｽ","電子ﾒｰﾙ 2 表示名","電子ﾒｰﾙ 2 ｱﾄﾞﾚｽ","ユーザー 3","ユーザー 4"';
    print OUT "\r\n";

    print OUT $output;

    close OUT;

    $self->info( "Exported LDIF data to $outfile" );

    return $output;
}

1;
