use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              NAME              => 'BBDB::Export',
              VERSION_FROM      => 'lib/BBDB/Export.pm',
              EXE_FILES         => [ qw[ bin/bbdb-export ] ],
              PREREQ_PM         => {
                                    'BBDB'            => 0,
                                    'Term::ANSIColor' => 0,
                                    'Pod::Usage'      => 0,
                                   },
              ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
               (ABSTRACT_FROM  => 'lib/BBDB/Export.pm', # retrieve abstract from module
                AUTHOR         => 'wu <VVu@geekfarm.org>') : ()),
);
