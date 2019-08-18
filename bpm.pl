#!/usr/bin/perl -s

BEGIN
{

  $usage = <<"  DONE"
  Usage:
  $0 [-h] [-ms] [-nb=INTEGER] [-ts=FRACTION] ARGS [ARGS ...]
    -h
        Display this help message.
    -ms
        Display timings in milliseconds.
        Default is to use seconds instead.
    -ts=FRACTION
        Specify a time signature with FRACTION, e.g. 6/8.
        Default is 4/4.
    -nb=INTEGER
        Specify a number of beats with INTEGER, e.g. 3.
        Default is 1.
    ARGS
        Provide the number of beats per minute, e.g. 128.
        More than one argument may be given.
  Example: $0 -ms -ts=3/4 96 155
  DONE
  ; #end of usage string

  if($h) #user wants help
  {
      print($usage);
      exit(0);
  } #end if

  if(!@ARGV)
  {
      warn("!:No arguments given.\n${usage}");
      exit(1);
  } #end if

  sub positive_integer($)
  {
      $_[0] > 0 and $_[0] eq int $_[0];
  } #end sub

  if($ms) #milliseconds switch
  {
      $main::time_factor = 60_000; #milliseconds per minute
      $main::time_unit = 'ms';
  } #end if
  else
  {
      $main::time_factor = 60; #seconds per minute
      $main::time_unit = 's';
  } #end else

  if($ts) #time signature switch
  {
      my($numerator, $denominator) = split('/', $ts);
      if(positive_integer($numerator) && positive_integer($denominator))
      {
          $main::beats_per_bar = $numerator;
          $main::note_value = $denominator;
      } #end if:if
      else
      {
          warn("!:Invalid time signature: ${ts}\n${usage}");
          exit(2);
      } # end if:else
  } #end if
  else
  {
      $main::beats_per_bar = 4;
      $main::note_value = 4;
  } #end else

  if($nb) #'number of beats' switch
  {
      if(positive_integer($nb))
      {
          $main::number_of_beats = $nb;
      } #end if:if
      else
      {
          warn("!:Invalid number of beats: ${nb}\n${usage}");
          exit(3);
      } #end if:else
  } #end if
  else
  {
      $main::number_of_beats = 1;
  } #end else

  sub beat_length($)
  {
      $time_factor * 4/$note_value / $_[0];
  } #end sub

  sub bar_length($)
  {
      $beats_per_bar * beat_length($_[0]);
  } #end sub

} #end BEGIN


### Main program ###

foreach $beats_per_minute(@ARGV)
{
    if(positive_integer($beats_per_minute))
    {
        printf
        (
            "%d BPM: %d beat%s = %g %s, bar = %g %s\n",
            $beats_per_minute,
            $number_of_beats,
            $number_of_beats == 1 ? "" : "s",
            beat_length($beats_per_minute) * $number_of_beats,
            $time_unit,
            bar_length($beats_per_minute),
            $time_unit
        );
    } #end foreach:if
    else
    {
        warn("!:Not a positive integer: ${beats_per_minute}\n${usage}");
    } #end foreach:else
} #end foreach

### End of main program ###
