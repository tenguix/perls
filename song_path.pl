#!/usr/bin/perl -s

use constant { FAILED => 0, MATCHED => 1, UNMATCHED => 2 };
$playlist_dir = qq($ENV{HOME}/.config/audacious/playlists);
$re_playlist_file = qr(\.audpl$);
$re_hex_escape = qr/%([A-F0-9][A-F0-9])/;
$re_file_prefix = qr(^file://);
@search_fields = qw(album artist title); #for now
$usage = sprintf("Usage: %s [-i] -[%s]=[/]expr[/] ...\n",
                 $0, join("|", @search_fields));
%search_fields = map{ $_, matcher($$_) } grep($$_, @search_fields);
die $usage unless scalar keys %search_fields;

opendir($dh, $playlist_dir)
        or die("!:Couldn't opendir $playlist_dir: $!");
while($playlist_file = readdir $dh) {
    next unless $playlist_file =~ $re_playlist_file;
    open($fh, "<", "$playlist_dir/$playlist_file")
            or die("!:Couldn't open $playlist_file: $!");
    my $current_uri, $match;
    while($line = readline $fh) {
        my($key, $value) = split('=', $line);
        $value =~ s/$re_hex_escape/chr hex $1/eg;
        if($key eq "uri") {
            if($match == MATCHED and not $seen{$current_uri}++) {
                print($current_uri);
            } #end while:while:if:if
            ($current_uri = $value) =~ s/$re_file_prefix//d;
            $match = UNMATCHED;
        } #end while:while:if
        elsif($match && exists $search_fields{$key}) {
            $match = $search_fields{$key}->($value);
        } #end while:while:elsif
    } #end while:while
} #end while

sub matcher ($) {
    my $string = shift;
    if($string =~ m{^/(.*)/$}) {
        if($i) { #case insensitive
            eval{ $string = qr/$1/i };
            die("!:Regex compilation failed: $!") if $@;
        } #end if:if
        else {
            eval{ $string = qr/$1/ };
            die("!:Regex compilation failed: $!") if $@;
        } #end if:else
        return sub{
            return $_[0] =~ $string;
        };
    } #end if
    elsif($i) { #case insensitive
        $string = CORE::fc($string);
        return sub{
            chomp $_[0];
            return $string eq CORE::fc($_[0]);
        };
    } #end elseif
    else {
        return sub{
            chomp $_[0];
            return $string eq $_[0];
        };
    } #end else
} #end matcher
