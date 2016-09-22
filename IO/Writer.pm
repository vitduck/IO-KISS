package IO::Writer; 

use Moose::Role; 
use namespace::autoclean; 
use experimental qw( signatures ); 

# from IO::KISS
my @write_methods = qw( print printf ); 

# somewhat akward delegation  
my %write_delegation = map { $_ => $_ } @write_methods;  

has 'writer', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_writer', 
    handles   => { %write_delegation, close_writer => 'close' }
); 

1 
