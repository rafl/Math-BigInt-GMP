use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Math-BigInt-GMP',
    'VERSION_FROM'	=> 'lib/Math/BigInt/GMP.pm', # finds $VERSION
    'PREREQ_PM'		=> {
				Math::BigInt => 1.60,
				Math::BigFloat => 1.35,
				Math::GMP => 2.03,
			   }, 
    'LIBS'		=> [''], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '', # e.g., '-I/usr/include/other'
);
