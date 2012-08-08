use warnings;
use strict;

package POSIX::1003::Time;
use base 'POSIX::1003::Module';

# Blocks resp. defined in time.h, limits.h
my @constants = qw/
  CLK_TCK CLOCKS_PER_SEC NULL
  TZNAME_MAX
 /;

our @IN_CORE  = qw/gmtime localtime/;

my @functions = qw/
  asctime ctime strftime
  clock difftime mktime
  tzset tzname/;
push @functions, @IN_CORE;

our %EXPORT_TAGS =
  ( constants => \@constants
  , functions => \@functions
  );

=chapter NAME

POSIX::1003::Time - POSIX handling time

=chapter SYNOPSIS

  use POSIX::1003::Time;

  tzset();      # set-up local timezone from $ENV{TZ}
  ($std, $dst) = tzname;  # timezone abbreviations

  $str = ctime($timestamp);   # is equivalent to:
  $str = asctime(localtime($timestamp))

  $str = strftime("%A, %B %d, %Y", 0, 0, 0, 12, 11, 95, 2);
  # $str contains "Tuesday, December 12, 1995"

  $timestamp = mktime(0, 30, 10, 12, 11, 95);
  print "Date = ", ctime($timestamp);

  print scalar localtime;
  my $year   = (localtime)[5] + 1900;

  $timespan  = difftime($end, $begin);

=chapter DESCRIPTION

=chapter CONSTANTS

=section Constants from time.h

  CLK_TCK CLOCKS_PER_SEC NULL

=section Constants from limits.h

  TXNAME_MAX

=chapter FUNCTIONS

=section Standard POSIX

B<Warning:> the functions M<asctime()>, M<mktime()>, and M<strftime()>
share a weird complex encoding with M<localtime()> and M<gmtime()>:
the month (C<mon>), weekday (C<wday>), and yearday (C<yday>) begin at
zero.  I.e. January is 0, not 1; Sunday is 0, not 1; January 1st is 0,
not 1.  The year (C<year>) is given in years since 1900.  I.e., the year
1995 is 95; the year 2001 is 101.

=function asctime SEC, MIN, HOUR, MDAY, MON, YEAR, ...
The C<asctime> function uses C<strftime> with a fixed format, to produce
timestamps with a trailing new-line.  Example:

  "Sun Sep 16 01:03:52 1973\n"

The parameter order is the same as for M<strftime()> without the C<$fmt>:

  my $str = asctime($sec, $min, $hour, $mday, $mon, $year,
                 $wday, $yday, $isdst);

=function clock
The amount of spent processor time in microseconds.

=function ctime TIMESTAMP

  # equivalent
  my $str = ctime $timestamp;
  my $str = asctime localtime $timestamp;

=function difftime TIMESTAMP, TIMESTAMP
Difference between two TIMESTAMPs, which are floats.

  $timespan = difftime($end, $begin);

=function mktime SEC, MIN, HOUR, MDAY, MON, YEAR, ...
Convert date/time info to a calendar time.
Returns "undef" on failure.

   my $t = mktime(sec, min, hour, mday, mon, year,
              wday = 0, yday = 0, isdst = -1)

  # Calendar time for December 12, 1995, at 10:30 am
  $timestamp = mktime(0, 30, 10, 12, 11, 95);
  print "Date = ", ctime($time_t);

=function strftime FMT, SEC, MIN, HOUR, MDAY, MON, YEAR, ...
The formatting of C<strftime> is extremely flexible but the parameters
are quite tricky.  Read carefully!

  my $str = strftime($fmt, $sec, $min, $hour,
      $mday, $mon, $year, $wday, $yday, $isdst);

If you want your code to be portable, your format (FMT) argument
should use only the conversion specifiers defined by the ANSI C
standard (C89, to play safe).  These are C<aAbBcdHIjmMpSUwWxXyYZ%>.
But even then, the results of some of the conversion specifiers are
non-portable.

=function tzset
Set-up local timezone from C<$ENV{TZ}> and the OS.

=function tzname
Returns the strings to be used to represent Standard time (STD)
respectively Daylight Savings Time (DST).

  tzset();
  my ($std, $dst) = tzname;
=cut

# Everything in POSIX.xs

=function gmtime [TIME]
Simply L<perlfunc/gmtime>

=function localtime [TIME]
Simply L<perlfunc/localtime>
=cut

1;
