###############################################################################
# core math lib for BigInt, representing big numbers by the GMP library

package Math::BigInt::GMP;

use strict;
use 5.005;
# use warnings; # dont use warnings for older Perls

require Exporter;
require DynaLoader;

use vars qw/@ISA $VERSION/;
@ISA = qw(Exporter DynaLoader);
$VERSION = '1.13';

bootstrap Math::BigInt::GMP $VERSION;

sub import { }		# catch and throw away

##############################################################################
# actual math code

sub _sub
  {
  # $x is always larger than $y! So overflow/underflow can not happen here
  if ($_[3])
    {
    $_[2] = Math::BigInt::GMP::sub_two($_[1],$_[2]); return $_[2];
    }
  Math::BigInt::GMP::_sub_in_place($_[1],$_[2]);
  }                                                                             

sub _div
  {
  if (wantarray)
    {
    # return (a/b,a%b)
    my $r;
    ($_[1],$r) = Math::BigInt::GMP::bdiv_two($_[1],$_[2]); 
    return ($_[1], $r);
    }
  # return a / b
  $_[1] = Math::BigInt::GMP::div_two($_[1],$_[2]);
  }

##############################################################################
# testing

sub _len
  {
  # return length, aka digits in decmial, costly!!
  length( Math::BigInt::GMP::_num(@_) );
  }

sub _digit
  {
  # return the nth digit, negative values count backward; this is costly!
  my ($c,$x,$n) = @_;

  $n++; substr( Math::BigInt::GMP::_num($c,$x), -$n, 1 );
  }

###############################################################################
# check routine to test internal state of corruptions

sub _check
  {
  # no checks yet, pull it out from the test suite
  my ($x) = $_[1];
  return "$x is not a reference to Math::BigInt::GMP"
   if ref($x) ne 'Math::BigInt::GMP';
  0;
  }

1;
__END__

=pod

=head1 NAME

Math::BigInt::GMP - Use the GMP library for Math::BigInt routines

=head1 SYNOPSIS

Provides support for big integer calculations via means of the GMP c-library.

Math::BigInt::GMP now no longer uses Math::GMP, but provides it's own XS layer
to access the GMP c-library. This cut's out another (perl sub routine) layer
and also reduces the memory footprint by not loading Math::GMP and Carp at
all.

=head1 LICENSE
 
This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself. 

=head1 AUTHOR

Tels <http://bloodgate.com/> in 2001-2003.

Thanx to Chip Turner for providing Math::GMP, which was inspiring my work.

=head1 SEE ALSO

L<Math::BigInt>, L<Math::BigInt::Calc>.

=cut
