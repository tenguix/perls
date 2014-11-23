#!/usr/bin/perl -s

sub read_value_from($)
{
    my $fname = shift;
    my $ret;

    unless(-r -T $fname) {
        die qq(!: "$fname": $!);
    }

    open(my $fh, "< $fname") or die qq(!: "$fname": $!);

    $ret = <$fh>;

    unless(eof $fh) {
        close($fh) or die qq(!: "$fname": $!);
    }

    return $ret;
}

sub actual_value($)
{
    sprintf "%d", $levels{"max"} * $_[0] / 100;
}

sub relative_level($) {
    sprintf "%d", 100 * $_[0] / $levels{"max"};
}

$sys_dir = "/sys/class/backlight/radeon_bl0";

%levels = (
    max => read_value_from("$sys_dir/max_brightness"),
    old => read_value_from("$sys_dir/brightness"),
    new => undef
);

if(1 < scalar @ARGV) {
    die qq(!: Usage: $0 [-f] [1-100]\n);
}

elsif($new = shift) {
    if($new =~ /^[0-9]+$/) {
        if($new < 1 || $new > 100) {
            die qq(!: $new: Invalid brightness level.);
        }
        elsif($new <= 10) {
            unless($f) {    #force.
                $new *= 10;
            }
        }
        $levels{"new"} = actual_value($new);
    }
    else {
        die qq(!: "$new": What the fuck is this);
    }

    if(open(my $fh, "|sudo tee $sys_dir/brightness")) {
        printf $fh ("%d" => $levels{"new"});
        close($fh) or die qq(!: "$sys_dir/brightness": $!);
    }
    else {
        die qq(!: Pipe to "$sys_dir/brightness": $!);
    }

    printf("\n%d%% => %d%%\n", relative_level($levels{"old"}), $new);
    # TODO: the old value is never right
}

else {
    printf "Current level: %3d%%\n", relative_level($levels{"old"});
}
