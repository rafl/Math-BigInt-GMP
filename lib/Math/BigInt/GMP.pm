###############################################################################
# core math lib for BigInt, representing big numbers by Math::GMP's

package Math::BigInt::GMP;

use 5.005;
use strict;
# use warnings; # dont use warnings for older Perls

require Exporter;

use vars qw/@ISA $VERSION/;
@ISA = qw(Exporter);

$VERSION = '1.04';
        
# todo: _from_hex _from_bin
#       _as_hex _as_bin
#	_and _or _xor

use Math::GMP;

# for _inc, _dec, _is_odd, _is_even, _is_one, _is_zero etc
my $zero = Math::GMP::new_from_scalar(0);		
my $one  = Math::GMP::new_from_scalar(1);
my $two  = Math::GMP::new_from_scalar(2);

##############################################################################
# create objects from various representations

sub _new
  {
  # (string) return ref to num
  my $d = $_[1];
  Math::GMP::new_from_scalar($$d);
  }                                                                             

sub _zero
  {
  Math::GMP::new_from_scalar(0);
  }

sub _one
  {
  Math::GMP::new_from_scalar(1);
  }

sub _copy
  {
  # return Math::GMP->new("$_[1]");	# this is O(N*N)
  $_[1]+0;				# this should be O(N)	
#  $_[1];		# Math::GMP::gmp_foo() already makes copy in every case
  }

sub import { }

##############################################################################
# convert back to string and number

sub _str
  {
  # make string
  my $r = Math::GMP::stringify_gmp($_[1]);
  \$r;
  }                                                                             

sub _num
  {
  # make a number
  # let Perl's atoi() handle this one
  Math::GMP::stringify_gmp($_[1]);
  # "$_[1]";
  }

##############################################################################
# actual math code

#sub _add { $_[1] += $_[2]; }
sub _add { $_[1] = Math::GMP::add_two($_[1],$_[2]); }

sub _sub
  {
  # $x is always larger than $y! So overflow/underflow can not happen here
  if ($_[3])
    {
    $_[2] = Math::GMP::sub_two($_[1],$_[2]); return $_[2];
   # $_[2] = $_[1] - $_[2]; return $_[2];
    }
#  else
#    {
   $_[1] = Math::GMP::sub_two($_[1],$_[2]); return $_[1];
#    $_[1] -= $_[2]; return $_[1];
#    }
  }                                                                             

#sub _mul { $_[1] *= $_[2]; }
sub _mul { $_[1] = Math::GMP::mul_two($_[1],$_[2]); }

#sub _mod { $_[1] %= $_[2]; }
sub _mod { $_[1] = Math::GMP::mod_two($_[1],$_[2]); }

sub _div {
    if (wantarray) {
        my $r = $_[1] % $_[2];
        $_[1] /= $_[2];
        return($_[1], $r);
    } else {
        $_[1] /= $_[2];
    }
    $_[1];
}

sub _inc { $_[1] = Math::GMP::add_two($_[1],$one); }
sub _dec { $_[1] = Math::GMP::sub_two($_[1],$one); }

# does not work
#sub _and { $_[1] &= $_[2]; }
#sub _xor { $_[1] ^= $_[2]; }
#sub _or  { $_[1] |= $_[2]; }

##############################################################################
# testing

sub _acmp
  {
  my ($c,$x, $y) = @_;

  $x <=> $y;
  }

sub _len
  {
  # return length, aka digits in decmial, costly!!
  length( Math::GMP::stringify_gmp($_[1]) );
  #length("$_[1]");
  }

sub _digit
  {
  # return the nth digit, negative values count backward; this is costly!
  my ($c,$x,$n) = @_;

  # $n++; substr("$x",-$n,1);
  $n++; substr( Math::GMP::stringify_gmp($x), -$n, 1 );
  }

sub _pow { $_[1] **= $_[2]; }

# does not work
#sub _rsft
#  {
#  # (X,Y,N) = @_; means X >> Y in base N
#  return undef if $_[3] != 2;
#  $_[1] = $_[1] >> $_[2];
#  }
#
#sub _lsft
#  {
#  # (X,Y,N) = @_; means X >> Y in base N
#  return undef if $_[3] != 2;
#  $_[1] = $_[1] << $_[2];
#  }

sub _gcd
  {
  $_[1] = Math::GMP::gcd_two($_[1],$_[2]);
  }

sub _fac
  {
  # factorial of $x
  my ($c,$x) = @_;

  my $n = _copy($c,$x);
  $x = $one;
  while (!_is_one($c,$n))
    {
    $x = Math::GMP::mul_two($x,$n); $n = Math::GMP::sub_two($n,$one);
    }
  $x; 
  }

##############################################################################
# _is_* routines

sub _is_zero
  {
  # return true if arg is zero
  $_[1] == $zero ? 1 : 0;
  }

sub _is_one
  {
  # return true if arg is one
  $_[1] == $one ? 1 : 0;
  }

sub _is_even { $_[1] % $two ? 0 : 1; }
sub _is_odd { $_[1] % $two ? 1 : 0; }

###############################################################################
# check routine to test internal state of corruptions

sub _check
  {
  # no checks yet, pull it out from the test suite
  my ($x) = $_[1];
  return "$x is not a reference to Math::GMP" if ref($x) ne 'Math::GMP';
  return 0;
  }

1;
__END__

=head1 NAME

Math::BigInt::GMP - Use Math::GMP for Math::BigInt routines

=head1 SYNOPSIS

Provides support for big integer calculations via means of Math::GMP, an
XS layer to the GMP c-library.

=head1 LICENSE
 
This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself. 

=head1 AUTHOR

Tels http://bloodgate.com in 2001.
The used module Math::GMP is by Chip Turner. Thanx!

=head1 SEE ALSO

L<Math::BigInt>, L<Math::BigInt::Calc>, L<Math::GMP>.

=cut
