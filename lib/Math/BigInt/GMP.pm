###############################################################################
# core math lib for BigInt, representing big numbers by Math::GMP's

package Math::BigInt::GMP;

use 5.005;
use strict;
# use warnings; # dont use warnings for older Perls

require Exporter;

use vars qw/ @ISA @EXPORT $VERSION/;
@ISA = qw(Exporter);

@EXPORT = qw(
        _add _mul _div _mod _sub
        _new
        _str _num _acmp _len
        _digit
        _is_zero _is_one
        _is_even _is_odd
        _check _zero _one _copy _len
	_pow _dec _inc
);
$VERSION = '1.01';
        
# todo: _from_hex _from_bin
#       _gcd
#	_and _or _xor

use Math::GMP;

##############################################################################
# create objects from various representations

sub _new
  {
  # (string) return ref to num
  my $d = $_[1];
  return Math::GMP->new($$d);
  }                                                                             

sub _zero
  {
  return Math::GMP->new(0);
  }

sub _one
  {
  return Math::GMP->new(1);
  }

sub _copy
  {
  # return Math::GMP->new("$_[1]");	# this is O(N*N)
  return $_[1]+0;			# this should be O(N)	
  }

##############################################################################
# convert back to string and number

sub _str
  {
  # make string
  my $x = $_[1];
  return \"$x";
  }                                                                             

sub _num
  {
  # make a number
  # let Perl's atoi() handle this one
  my $x = $_[1];
  return "$x";
  }


##############################################################################
# actual math code

sub _add { $_[1] += $_[2]; }                                                                             
sub _sub
  {
  # $x is always larger than $y! So overflow/underflow can not happen here
  if ($_[3])
    {
    $_[2] = $_[1] - $_[2]; return $_[2];
    }
  else
    {
    $_[1] -= $_[2]; return $_[1];
    }
  }                                                                             

sub _mul { $_[1] *= $_[2]; }                                                                             
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


sub _inc { ++$_[1]; }
sub _dec { --$_[1]; }

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
  return length("$_[1]");
  }

sub _digit
  {
  # return the nth digit, negative values count backward; this is costly!
  my ($c,$x,$n) = @_;

  $n++; return substr("$x",-$n,1);
  }

sub _pow { $_[1] **= $_[2]; }

##############################################################################
# _is_* routines

sub _is_zero
  {
  # return true if arg is zero
  return 1 if $_[1] == 0;
  return 0;
  }

sub _is_one
  {
  # return true if arg is one
  return 1 if $_[1] == 1;
  return 0;
  }

sub _is_even { $_[1] % 2 ? 0 : 1; }

sub _is_odd { $_[1] % 2 ? 1 : 0; }

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
