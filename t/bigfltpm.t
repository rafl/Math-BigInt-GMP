#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  $| = 1;
  unshift @INC, '../lib'; 	# for running manually
  unshift @INC, '../blib/arch';
  chdir 't' if -d 't';
  plan tests => 2042;
  }

use Math::BigInt lib => 'GMP';
use Math::BigFloat;

use vars qw ($class $try $x $y $f @args $ans $ans1 $ans1_str $setup $CL);
$class = "Math::BigFloat";
$CL = "Math::BigInt::GMP";
   
require 'bigfltpm.inc';	# all tests here for sharing
