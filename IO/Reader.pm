package IO::Reader; 

use Moose::Role; 
use namespace::autoclean; 

use experimental qw( signatures ); 

requires qw( _build_reader ); 

has 'reader', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_reader', 
    clearer   => '_clear_reader', 

    handles   => { 
        _slurp          => 'slurp', 
        _get_line       => 'get_line', 
        _get_lines      => 'get_lines', 
        _get_paragraph  => 'get_paragraph', 
        _get_paragraphs => 'get_paragraphs', 
        _chomp_reader   => 'chomp', 
        _close_reader   => 'close' 
    }
); 

1 
