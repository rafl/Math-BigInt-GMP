###############################################################################
# core math lib for BigInt, representing big numbers by the GMP library

package Math::BigInt::GMP;

use 5.005;
use strict;
# use warnings; # dont use warnings for older Perls

require Exporter;
require DynaLoader;

use vars qw/@ISA $VERSION/;
@ISA = qw(Exporter DynaLoader);

$VERSION = '1.12';

bootstrap Math::BigInt::GMP $VERSION;

BEGIN
  {
  *DESTROY = \&Math::BigInt::GMP::destroy;
  }

sub import { }		# catch and throw away

##############################################################################
# convert back to string and number

sub _num
  {
  # make a number
  # let Perl's atoi() handle this one
  Math::BigInt::GMP::__stringify($_[1]);
  }

##############################################################################
# actual math code

sub _sub
  {
  # $x is always larger than $y! So overflow/underflow can not happen here
  if ($_[3])
    {
    $_[2] = Math::BigInt::GMP::sub_two($_[1],$_[2]); return $_[2];
    }
  $_[1] = Math::BigInt::GMP::sub_two($_[1],$_[2]);
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
  length(Math::BigInt::GMP::__stringify($_[1]));
  }

sub _digit
  {
  # return the nth digit, negative values count backward; this is costly!
  my ($c,$x,$n) = @_;

  $n++; substr( Math::BigInt::GMP::__stringify($x), -$n, 1 );
  }

sub _modinv
  {
  # modular inverse
  my ($c,$x,$y) = @_;

  my $u = _zero($c); my $u1 = _one($c);
  my $a = _copy($c,$y); my $b = _copy($c,$x);

  # Euclid's Algorithm for bgcd(), only that we calc bgcd() ($a) and the
  # result ($u) at the same time. See comments in BigInt for why this works.
  my $q;
  ($a, $q, $b) = ($b, _div($c,$a,$b));          # step 1
  my $sign = 1;
  while (!_is_zero($c,$b))
    {
    my $t = _add($c,                            # step 2:
       _mul($c,_copy($c,$u1), $q) ,             #  t =  u1 * q
       $u );                                    #     + u
    $u = $u1;                                   #  u = u1, u1 = t
    $u1 = $t;
    $sign = -$sign;
    ($a, $q, $b) = ($b, _div($c,$a,$b));        # step 1
    }

  # if the gcd is not 1, then return NaN
  return (undef,undef) unless _is_one($c,$a);

  $sign = $sign == 1 ? '+' : '-';
  ($u1,$sign);
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
