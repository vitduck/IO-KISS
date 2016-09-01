package IO::KISS; 

# cpan
use Moose; 
use MooseX::Types; 
use MooseX::Types::Moose qw/Str Undef Ref ArrayRef GlobRef/; 
use namespace::autoclean; 

# pragma
use autodie; 
use warnings FATAL => 'all'; 
use feature qw/switch/; 
use experimental qw/signatures smartmatch/; 

# Moose attributes 
has 'stream', ( 
    is        => 'ro', 
    isa       => Str | Ref, 
    required  => 1, 
); 

# read | write | append 
has 'mode', ( 
    is        => 'ro', 
    isa       => enum([ qw/r w a/ ]),   
    required  => 1, 
); 

has 'fh', ( 
    is        => 'ro', 
    isa       => GlobRef, 
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        my $fh; 
        given ( $self->mode ) { 
            when ( 'r' ) { open $fh, '<' , $self->stream } 
            when ( 'w' ) { open $fh, '>' , $self->stream } 
            when ( 'a' ) { open $fh, '>>', $self->stream }
        }
        return $fh; 
    }, 
); 

has '_separator', ( 
    is        => 'rw', 
    isa       => Str | Undef, 
    init_arg  => 'undef', 
    default   => "\n", 
); 

# slurp mode 
has 'slurp', ( 
    is        => 'ro', 
    isa       => Str,  
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        $self->_separator(undef); 
        return $self->readline;  
    }
); 

# line mode 
has 'line', ( 
    is        => 'ro', 
    isa       => ArrayRef[Str],  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        return $self->readline; 
    },  
    handles   => { 
        get_line  => 'shift', 
        get_lines => 'elements', 
    }, 
); 

# paragraph mode 
has 'paragraph', ( 
    is        => 'ro', 
    isa       => ArrayRef[Str],  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 
    default   => sub ( $self ) { 
        $self->_separator(''); 
        return $self->readline;  
    }, 
    handles   => { 
        get_paragraph  => 'shift', 
        get_paragraphs => 'elements', 
    }, 
); 

# Moose methods 
# Error: Prototype mismatch: sub IO::KISS::read (*\$$;$) vs none
sub readline ( $self ) { 
    my @lines  = do { 
        local $/ = $self->_separator; 
        readline $self->fh;  
    };  
    chomp @lines; 
    return defined $self->_separator ? \@lines : shift @lines; 
} 

sub print ( $self, @items ) { 
    print {$self->fh} "@items\n"; 
} 

sub printf ( $self, $format, @items ) { 
    printf {$self->fh} $format, @items; 
}

# simple constructors 
override BUILDARGS => sub ( $class, @args ) { 
    return @args == 2  ? { stream => $args[0], mode => $args[1] } : super; 
}; 

# speed-up object construction 
__PACKAGE__->meta->make_immutable;

1; 
