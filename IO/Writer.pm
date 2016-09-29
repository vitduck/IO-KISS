package IO::Writer; 

use Moose::Role; 
use namespace::autoclean; 

use experimental qw( signatures ); 

requires qw( _build_writer ); 

has 'writer', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_writer', 
    clearer   => '_clear_writer', 

    handles   => { 
        _print        => 'print', 
        _printf       => 'printf', 
        _close_writer => 'close' 
    }
); 

1 
