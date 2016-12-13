package IO::Cache; 

use Moose::Role; 
use MooseX::Types::Moose 'HashRef';  
use IO::KISS; 

use namespace::autoclean; 

requires '_build_cache';  

has 'cache', ( 
    is        => 'ro', 
    isa       => HashRef, 
    init_arg  => undef,
    traits    => [ 'Hash' ], 
    lazy      => 1, 
    builder   => '_build_cache',
    clearer   => 'clear_cache', 
    handles   => { get_cached => 'get' }
); 

1 
