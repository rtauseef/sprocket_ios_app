my $DEBUG = 0;
my $fontChange = 1;

if( @ARGV < 1 )
{
  print <<EOF

Usage Instructions:
  perl $ARGV[0] <templateFile.svg>

  This script modifies the size of the description font by $fontChange points.

EOF
;
  exit;
}

# iterate over all lines in the file
while( <> )
{
  if( /(\s*)(<photogram:descriptionSize>)\s*(\d+)\s*(<\/photogram:descriptionSize>)/ )
  {
    print $1 . $2 . ($3 + $fontChange) . $4 . "\n";
  }
  else
  {
    print $_;
  }
}

1;
