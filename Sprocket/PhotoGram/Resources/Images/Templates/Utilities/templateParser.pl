my $DEBUG = 0;
my $modifying = 0;            # if true, we are truncating textbox and photo-hole dimension data
my $omitting = 0;             # if true, we are ignoring junk portions of the file
my $ignoreNamespaces = 1;     # if true, we are ignoring all lines that contain namespace data
my $fontReductionFactor = 1;  # we divide all font sizes by this number before spitting them back out
my $justEndedElement    = 0;

if( @ARGV < 1 )
{
  print <<EOF

Usage Instructions:
  perl $ARGV[0] <templateFile.svg>

  This script takes a single file as an argument.  That file is expected to be a .svg file.
  That file is also expected to:
    - need its fonts reduced by a factor of $fontReductionFactor
    - need some of its <rdf:Description> sections to be split up
    - need some namespace information removed
    - need its textbox and photo-hole placement and dimension data truncated

EOF
;
  exit;
}

sub roundToNearestHalf
{
  my $wholeNum;
  my $tenths;
  
  $n = @_[0];
  
  $n =~ /(\d+)\.?(\d+)?/;
  
  $wholeNum = $1;
  $tenths = $2;
  
  if( $tenths < 3 )
  {
    $tenths = 0;
  }  
  elsif( $tenths < 7 )
  {
    $tenths = 5;
  }
  else
  {
    $wholeNum++;
    $tenths = 0;
  }
  
  return( "$wholeNum" . '.' . "$tenths" );
}

# iterate over all lines in the file
while( <> )
{
    # yeah... just rewrite this if it stops working...
    if( /id=\"([a-zA-Z]+)\"\sx=\"([\.\d]+)\"\sy=\"([\.\d]+)\"\sfill=\"([a-zA-z]+)\"\swidth=\"([\.\d]+)\"\sheight=\"([\.\d]+)\"/ )
    {
      # take the bad data and turn it into good data
      my $id     = $1;
      my $x      = sprintf("%.0f", $2);
      my $y      = sprintf("%.0f", $3);
      my $fill   = $4;
      my $width  = sprintf("%.0f", $5);
      my $height = sprintf("%.0f", $6);

      if( $id =~ /descriptionBox/i ||
          $id =~ /picBox/i         ||
          $id =~ /locationBox/i    || $id =~ /locationIconBox/i ||
          $id =~ /ISOBox/i         || $id =~ /ISOIconBox/i      ||
          $id =~ /shutterBox/i     || $id =~ /shutterIconBox/i  ||
          $id =~ /dateBox/i        || $id =~ /dateIconBox/i     || $id =~ /calendarIconBox/i ||
          $id =~ /likesBox/i       || $id =~ /likesIconBox/i    ||
          $id =~ /commentsBox/i    || $id =~ /commentsIconBox/i   )
      {
        $x = roundToNearestHalf($x);
        $y = roundToNearestHalf($y);
        $width = roundToNearestHalf($width);
        $height = roundToNearestHalf($height);
        
        # look-- we can see the good data in a nice format if we want to :) 
        print "\nid=$id\nx=$x\ny=$y\nfill=$fill\nwidth=$width\nheight=$height\n"  if( $DEBUG );

        # write the good data into the new file
        print "\t<rect id=\"$id\" x=\"$x\" y=\"$y\" fill=\"$fill\" width=\"$width\" height=\"$height\"/>\n";
      }
      else
      {
        print $_;
      }
    }
    # don't modify anything we weren't expecting to change
    else
    {
      print $_;
    }
}

1;
