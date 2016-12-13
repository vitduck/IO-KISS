package IO::KISS; 

use Moose; 
use MooseX::Types::Moose qw/Bool Str Ref GlobRef/;  
use Moose::Util::TypeConstraints 'enum';  

use namespace::autoclean; 
use feature qw/state switch/;  
use experimental qw/signatures smartmatch/;  

has 'io', ( 
    is        => 'ro', 
    isa       => Str | Ref, 
    reader    => 'get_io'
); 

has 'mode', ( 
    is        => 'ro', 
    isa       => enum( [ qw/r w a/ ] ),  
    required  => 1, 
    reader    => 'get_mode',
); 

has 'fh', ( 
    is        => 'ro', 
    isa       => GlobRef, 
    lazy      => 1, 
    init_arg  => undef,
    reader    => 'get_fh', 
    clearer   => 'clear_fh', 
    builder   => '_build_fh' 
); 

has '_chomp', ( 
    is        => 'ro', 
    isa       => Bool, 
    traits    => [ 'Bool' ], 
    lazy      => 1, 
    init_arg  => undef,
    default   => 0, 
    handles   => { chomp => 'set' }
);

# simplified costructor
override BUILDARGS => sub ( $class, @args ) { 
    return 
        @args == 2 
        ? { io => $args[0], mode => $args[1] }  
        : super 
}; 

# read ( scalar )
sub slurp ( $self ) { 
    return scalar $self->readline( undef ) 
} 

sub get_line ( $self ) { 
    return scalar $self->readline          
}  

sub get_paragraph ( $self ) { 
    return scalar $self->readline( '' )    
}

# read ( list )
sub get_lines ( $self ) { 
    return $self->readline       
}

sub get_paragraphs ( $self ) { 
    return $self->readline( '' ) 
}

# write 
sub print ( $self, @items ) { 
    print { $self->get_fh } "@items\n"       
} 

sub printf ( $self, $format, @items ) { 
    printf { $self->get_fh } $format, @items 
} 

# wrapper of perl's open 
sub open ( $self, $io ) { 
    use autodie 'open'; 
    my $fh; 

    given ( $self->get_mode ) { 
        when ( 'r' ) { open $fh, '<' , $io } 
        when ( 'w' ) { open $fh, '>' , $io } 
        when ( 'a' ) { open $fh, '>>', $io }
    }

    return $fh; 
} 

sub close ( $self ) { 
    use autodie 'close'; 
    close $self->get_fh 
} 

# wrapper of perl's readline
# the wantarray test differentiate get_line and get_lines 
sub readline ( $self, $separator = "\n" ) { 
    return (
        wantarray 
        ? do { 
            my @reads = do { 
                local $/ = $separator; 
                readline $self->get_fh 
            }; 
            chomp @reads if @reads && $self->_chomp; 
            @reads 
        } 
        : do { 
            my $read = do { 
                local $/ = $separator; 
                readline $self->get_fh 
            }; 
            chomp $read if $read && $self->_chomp; 
            $read  
        }  
    )
} 

# build fh to either a file or string 
sub _build_fh ( $self ) { 
    return $self->open( $self->get_io )
}

__PACKAGE__->meta->make_immutable;

1 
