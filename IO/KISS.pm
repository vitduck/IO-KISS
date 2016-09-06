package IO::KISS; 

use Moose; 
use MooseX::Types; 
use MooseX::Types::Moose qw/Undef Str Ref ArrayRef GlobRef/; 

use strictures 2; 
use namespace::autoclean; 
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
    isa       => enum([ qw( r w a ) ]),   
    required  => 1, 
); 

has 'fh', ( 
    is        => 'ro', 
    isa       => GlobRef, 
    lazy      => 1, 
    init_arg  => undef,
    
    default   => sub ( $self ) { 
        use autodie qw/open/; 
        my $fh; 
        
        given ( $self->mode ) { 
            when ( 'r' ) { open $fh, '<' , $self->stream } 
            when ( 'w' ) { open $fh, '>' , $self->stream } 
            when ( 'a' ) { open $fh, '>>', $self->stream }
        }

        return $fh; 
    }
); 

has 'separator', ( 
    is        => 'ro', 
    isa       => Str | Undef, 
    lazy      => 1, 
    init_arg  => undef, 
    writer    => '_set_separator', 
    default   => "\n", 
); 

has 'slurp_mode', ( 
    is        => 'ro', 
    isa       => Str,  
    lazy      => 1, 
    init_arg  => undef, 
    reader    => 'get_string',  

    default   => sub ( $self ) { 
        $self->_set_separator(undef); 
        return $self->read_fh; 
    } 
); 

has 'line_mode', ( 
    is        => 'ro', 
    isa       => ArrayRef[Str],  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 

    default   => sub ( $self ) { 
        return $self->read_fh; 
    },  

    handles   => { 
        get_line  => 'shift', 
        get_lines => 'elements' 
    },  
); 

has 'paragraph_mode', ( 
    is        => 'ro', 
    isa       => ArrayRef[Str],  
    traits    => ['Array'],
    lazy      => 1, 
    init_arg  => undef, 

    default   => sub ( $self ) { 
        $self->_set_separator(''); 
        return $self->read_fh; 
    },  

    handles   => { 
        get_paragraph  => 'shift', 
        get_paragraphs => 'elements' }, 
); 

sub read_fh ( $self ) { 
    # list context;
    chomp ( 
        my @lines  = do { 
            local $/ = $self->separator; 
            readline $self->fh;  
        }   
    ); 

    # slurp -> undef -> scalar 
    # line | paragraph -> arrayref
    return defined $self->separator ? \@lines : shift @lines; 
} 

sub close ( $self ) { 
    use autodie qw/close/; 
    close $self->fh; 
} 

sub print ( $self, @items ) { 
    print {$self->fh} "@items\n"; 
} 

sub printf ( $self, $format, @items ) { 
    printf {$self->fh} $format, @items; 
}

override BUILDARGS => sub ( $class, @args ) { 
    return @args == 2  ? { stream => $args[0], mode => $args[1] } : super; 
}; 

__PACKAGE__->meta->make_immutable;

1; 
