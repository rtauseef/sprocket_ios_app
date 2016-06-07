my $DEBUG = 0;
my $directory = '.';

print <<EOF

Attempting to run templateParser.pl on every file in the current directory...

That's all this script does.  No arguments, no options, just run templateParser.pl 
  on every file in the current directory.

The usage intentions for this script: 
  - copy it and tmeplateParser.pl into a directory full of .svg files, 
    then run it from that location.

EOF
;

opendir (DIR, $directory) or die $!;

while (my $file = readdir(DIR))
{
  print "$file\n"  if( $DEBUG );

  if( $file =~ /.+5x7\.svg$/ )
  {
    # run templateParser.pl to create a new file called <filename>_new
    my $outputFile = "$file" . "_new";
    print "\nperl 5x7FontIncreaser.pl $file > $outputFile...\n";
    `perl 5x7FontIncreaser.pl $file > $outputFile`;

    # move the new file into the existing file
    print "mv $outputFile $file...\n";
    `mv $outputFile $file`;
  }
}

1;
