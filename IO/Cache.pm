package IO::Cache; 

use IO::KISS; 

use Moose::Role; 
use MooseX::Types::Moose 'HashRef';  
use namespace::autoclean; 

requires '_build_cache'; 

has 'cache', ( 
    is        => 'ro', 
    isa       => HashRef, 
    init_arg  => undef, 
    traits    => [ 'Hash' ], 
    lazy      => 1, 
    builder   => '_build_cache',
    clearer   => '_clear_cache' 
); 

1 
