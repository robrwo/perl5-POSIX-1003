use warnings;
use strict;

package POSIX::1003::OS;
use base 'POSIX::1003::Module';

# Blocks resp from limits.h
my @constants = qw/
 ARG_MAX NGROUPS_MAX OPEN_MAX TMP_MAX
 /;

# Blocks resp from sys/utsname.h
my @functions = qw/uname/;

our %EXPORT_TAGS =
 ( constants => \@constants
 , functions => \@functions
 );

=chapter NAME

POSIX::1003::OS - POSIX for the file-system

=chapter SYNOPSIS

  use POSIX::1003::OS qw(uname TMP_MAX);
  my ($sys, $node, $rel, $version, $machine) = uname();
  print TMP_MAX;

=chapter DESCRIPTION
You may also need M<POSIX::1003::Pathconf>.

=chapter CONSTANTS

=section Constants from limits.h

 ARG_MAX       Max bytes of args + env for exec
 NGROUPS_MAX
 OPEN_MAX      Max # files that one process can have open
 TMP_MAX       Min # of unique filenames generated by tmpnam

=chapter FUNCTIONS

=function uname 

Get the name of current operating system.

 my ($sysname, $node, $release, $version, $machine) = uname();

Note that the actual meanings of the various fields are not
that well standardized: do not expect any great portability.
The C<$sysname> might be the name of the operating system, the
C<$nodename> might be the name of the host, the C<$release> might be
the (major) release number of the operating system, the
C<$version> might be the (minor) release number of the operating
system, and C<$machine> might be a hardware identifier.
Maybe.

=cut

1;
