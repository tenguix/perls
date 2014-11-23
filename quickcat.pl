#!/usr/bin/perl -s


use File::Find;


if ($dir)
{
    -d $dir || die qq(!:"$dir" - Not a directory!/);
    -r $dir || die qq(!:"$dir" - Not readable!);

    find({ no_chdir => 1, wanted => \&display_file }, $dir);
} 


map(display_file(), @ARGV) if @ARGV;


sub display_file
{

    return unless -f (my $file = $_);

    if (-r $file)
    {
        if (-T $file)
        {
            open(FH, "<", $file) || die qq(!:Couldn't open "$file"!);
            
            if (eof FH)
            {
                print "(empty) $file\n";
            }
            else
            {
                my $str = <FH>;
                if (eof FH)
                {
                    print "$file: $str";
                }
                else
                {
                    print "$file:\n";
                    seek(FH, 0, 0);
                    $.--;
                    printf("%6d\t%s", $., $_) while <FH>;
                }
                
                close(FH) || die qq(!:Couldn't close "$file"!);

            }
        }
        else
        {
            print "(binary) $file\n";
        }
    }
    else
    {
        warn qq(!:"$file" not readable);
    }
}
