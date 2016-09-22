package IO::Reader; 

use Moose::Role; 
use namespace::autoclean; 
use experimental qw( signatures ); 

# from IO::KISS
my @read_methods  = qw( slurp get_line get_lines get_paragraph get_paragraphs ); 

# somewhat akward delegation  
my %read_delegation  = map { $_ => $_ } @read_methods;

has 'reader', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_reader', 
    handles   => { %read_delegation, close_reader => 'close' }
); 

1 
