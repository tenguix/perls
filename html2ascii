#!/usr/bin/perl -s

use HTML::FormatText;


sub asciize ($)
{

    my $str = shift;

     # Only keep printable ascii chars
    $str =~ tr/\n\t\040-\176//cd;

=head superfluous
     # Expand tabs 
    1 while $str =~ s/\t/$" x ($ts - pos() % $ts)/e;
=cut
    
    return $str;

}

sub output_handle ($)
{

    my $outfile = my $infile = shift;

    unless ($outfile =~ s/\.\Khtml?$/txt/)
    {
        warn qq(!: "$infile" has an invalid extension.\n);
        return;
    }
    
    if ($save || $store)
    {
        if (-e $outfile)
        {
            if (rename($outfile, $outfile.'~'))
            {
                if ($verbose)
                {
                    print STDERR qq($outfile .= '~'\n);
                }
            }
            else
            {
                warn qq(!: Couldn't rename "$outfile": $!);
                return;
            }
        }
        open(my $fh, "> $outfile")
        || die qq(!: Couldn't open "$outfile" for writing: $!);

        if ($verbose)
        {
            print STDERR qq(> $outfile\n);
        }

        return $fh;
    }
    else
    {
        return \*STDOUT;
    }

}


 # Don't do anything if there's nothing to do

die "!: Usage: $0 [OPTIONS] FILE [FILE..]\n" unless @ARGV;


 # Assign switch defaults

$margin //=  2;
$width  //= 79;
$ts     //=  8;

 # Make $verbose point to $v switch

*verbose = \$v;

while ($infile = shift)
{
    if (-f $infile)
    {
        my $text = HTML::FormatText->format_file
        (
            $infile,
            leftmargin => $margin,
            rightmargin => $width
        );

        if ($write_handle = output_handle($infile))
        {
            print $write_handle asciize($text);

            eof $write_handle
            || close $write_handle
            || die qq(!: "$write_handle" - couldn't close: $!);
        }

    }
    else
    {
        warn(qq/!: "$infile" - file not found.\n/);
    }
}
