#!/usr/bin/perl -w

use Test;
use strict;

BEGIN
  {
  $| = 1;
  unshift @INC, '../lib'; # for running manually
  unshift @INC, './t'; # to locate the testing files
  # chdir 't' if -d 't';
  plan tests => 1277;
  }

use Math::BigInt lib => 'GMP';
use Math::BigFloat;

use vars qw ($class $try $x $y $f @args $ans $ans1 $ans1_str $setup);
$class = "Math::BigFloat";
   
require 'bigfltpm.inc';	# all tests here for sharing
