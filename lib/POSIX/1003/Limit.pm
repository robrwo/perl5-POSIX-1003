use warnings;
use strict;

package POSIX::1003::Limit;
use base 'POSIX::1003';

use Carp    'croak';

my (@ulimit, @rlimit, @constants, @functions);
our %EXPORT_TAGS =
  ( ulimit    => \@ulimit
  , rlimit    => \@rlimit
  , functions => \@functions
  , table     => [ qw/%ulimit %rlimit/ ]
  );

my  ($ulimit, $rlimit);
our (%ulimit, %rlimit);
my  ($rlim_saved_max, $rlim_saved_cur, $rlim_infinity);

BEGIN {
    # initialize the :constants export tag
    my @ufuncs = qw/ulimit ulimit_names/;
    my @rfuncs = qw/getrlimit setrlimit rlimit_names/;
    my @rconst = qw/RLIM_SAVED_MAX RLIM_SAVED_CUR RLIM_INFINITY/;

    $ulimit    = ulimit_table;
    @ulimit    = (keys %$ulimit, @ufuncs, '%ulimit');
    tie %ulimit, 'POSIX::1003::ReadOnlyTable', $ulimit;

    $rlimit    = rlimit_table;
    @rlimit    = (keys %$rlimit, @rfuncs, @rconst, '%rlimit');
    tie %rlimit, 'POSIX::1003::ReadOnlyTable', $rlimit;

    push @constants, keys %$ulimit, keys %$rlimit;
    push @functions, @ufuncs, @rfuncs;

    # Special meaning for
    $rlim_saved_max = delete $rlimit->{RLIM_SAVED_MAX};
    $rlim_saved_cur = delete $rlimit->{RLIM_SAVED_CUR};
    $rlim_infinity  = delete $rlimit->{RLIM_INFINITY};
}

sub RLIM_SAVED_MAX { $rlim_saved_max }
sub RLIM_SAVED_CUR { $rlim_saved_cur }
sub RLIM_INFINITY  { $rlim_infinity  }

=chapter NAME

POSIX::1003::Limit - POSIX access to ulimit and rlimit

=chapter SYNOPSIS

  # ULIMIT support

  use POSIX::1003::Limit; # load all names

  use POSIX::1003::Limit qw(ulimit);
  # keys are strings!
  $size = ulimit('UL_GETFSIZE');

  use POSIX::1003::Limit qw(ulimit UL_GETFSIZE);
  $size = UL_GETFSIZE;   # constants are subs

  use POSIX::1003::Limit '%ulimit';
  my $key = $ulimit{UL_GETFSIZE};
  $ulimit{_SC_NEW_KEY} = $key_code;
  $size = ulimit($key);

  print "$_\n" for keys %ulimit;

  # RLIMIT support

  use POSIX::1003::Limit ':rlimit';

  my ($cur, $max, $success) = getrlimit('RLIMIT_CORE');
  my ($cur, $max) = getrlimit('RLIMIT_CORE');
  my $cur = RLIMIT_CORE;

  my $success = setrlimit('RLIMIT_CORE', 1e6, 1e8);
  setrlimit('RLIMIT_CORE', 1e6) or die;
  setrlimit('RLIMIT_CORE', RLIM_SAVED_MAX, RLIM_INFINITY);
  RLIMIT_CORE(1e6, 1e8);

=chapter DESCRIPTION
This module provides access to the "ulimit" (user limit) and "rlimit"
(resource limit) handling.  On most systems, C<ulimit()> is succeeded
by C<rlimit()> hence provides a very limited set of features.

=chapter FUNCTIONS

=section Standard POSIX

=function ulimit NAME
Returns the ulimit value related to the NAMEd constant.  The NAME
must be a string. C<undef> will be returned when the NAME is not
known by the system.

  my $filesize = ulimit('UL_GETFSIZE') || SSIZE_MAX;
=cut

sub ulimit($;$)
{   my $key = shift // return;
    if(@_)
    {   $key =~ /^UL_SET|^SET_/
            or croak "pass the constant name as string ($key)";
        my $id  = $ulimit->{$key} // return;
        return _ulimit($id, shift);
    }
    else
    {   $key =~ /^UL_GET|^GET_/
            or croak "pass the constant name as string ($key)";
        my $id  = $ulimit->{$key} // return;
        _ulimit($id, 0);
    }
}

sub _create_constant($)
{   my ($class, $name) = @_;
    if($name =~ m/^RLIMIT_/)
    {   my $id = $rlimit->{$name} // return sub() {undef};
        return sub(;$$) { @_ ? _setrlimit($id, @_) : (_getrlimit($id))[0] };
    }
    else
    {   my $id = $ulimit->{$name} // return sub() {undef};
        return $name =~ m/^UL_GET|^GET_/
           ? sub() {_ulimit($id, 0)} : sub($) {_ulimit($id, shift)};
    }
}

=function getrlimit RESOURCE

  my ($cur, $max, $success) = getrlimit('RLIMIT_CORE');
  my ($cur, $max) = getrlimit('RLIMIT_CORE');
=cut

sub getrlimit($)
{   my $key = shift // return;
    $key =~ /^RLIMIT_/
        or croak "pass the constant name as string ($key)";
 
    my $id  = $rlimit->{$key};
    defined $id ? _getrlimit($id) : ();
}

=function setrlimit RESOURCE, CUR, [MAX]
  my $success = setrlimit('RLIMIT_CORE', 1e6, 1e8);
  setrlimit('RLIMIT_CORE', 1e6) or die;

  # warning: the key is quoted, the values are not (because those
  # represent constants)
  setrlimit('RLIMIT_CORE', RLIM_SAVED_MAX, RLIM_INFINITY);
=cut

sub setrlimit($$;$)
{   my ($key, $cur, $max) = @_;
    $key =~ /^RLIMIT_/
        or croak "pass the constant name as string ($key)";
 
    my $id  = $rlimit->{$key};
    $max //= RLIM_INFINITY;
    defined $id ? _setrlimit($id, $cur, $max) : ();
}

=function setrlimit RESOURCE, CUR, [MAX]
  my $success = setrlimit('RLIMIT_CORE', 1e6, 1e8);

=section Additional

=function ulimit_names
Returns a list with all known names, unsorted.
=cut

sub ulimit_names() { keys %$ulimit }

=function rlimit_names
Returns a list with all known resource names, unsorted.
=cut

sub rlimit_names() { keys %$rlimit }

=chapter CONSTANTS

=over 4
=item B<%ulimit>
This exported variable is a tied HASH which maps C<UL_*> names
on unique numbers, to be used with M<ulimit()>.

=item B<%rlimit>
This exported variable is a tied HASH which maps C<RLIMIT_*> names
on unique numbers, to be used with M<getrlimit()> and M<setrlimit()>.
=back
=cut


1;