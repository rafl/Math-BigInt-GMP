use ExtUtils::MakeMaker;

sub MY::metafile {
  package MY;
  my $self = shift;
  if (!eval { require YAML; 1 })
    {
    warn ("YAML not installed, make dist will not override metafile");
    return $self->SUPER::metafile_target(@_);
    }

  require YAML::Node;
  my $node = new YAML::Node {};

  $node->{name}                 = $self->{DISTNAME};
  $node->{author}               = 'Tels';
  $node->{version}              = $self->{VERSION};
  $node->{version_from}         = $self->{VERSION_FROM};
  $node->{license}              = 'perl';
  $node->{distribution_type}    = 'module';
  $node->{generated_by}         = "$self->{DISTNAME} version $self->{VERSION}";
  $node->{installdirs}          = 'site';
  $node->{requires}             = $self->{PREREQ_PM};

  my $dump = YAML::Dump( $node );

  $dump =~ s/^(.*)$/\t\$(NOECHO) \$(ECHO) "$1" >>META.yml/gm;
  $dump =~ s/>>META\.yml/>META.yml/;

  "metafile:\n$dump";
  }

WriteMakefile(
    'NAME'		=> 'Math::BigInt::GMP',
    'VERSION_FROM'	=> 'lib/Math/BigInt/GMP.pm',
    'PREREQ_PM'		=> {
				Math::BigInt => 1.82,
				XSLoader => 0.02,
			   }, 
    'LIBS'		=> ['-lgmp'],
);
