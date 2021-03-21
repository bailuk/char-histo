#!/usr/bin/env perl6


sub initHisto() {
    my %h;
    my %histo = 'col' => 1, 'total' => 0, 'lines' => 1, 'histo' => %h;
    %histo;
}


sub addChar(%histo, $c) {

    %histo{'histo'}{$c}{'count'}++;        

    %histo{'histo'}{$c}{'last_line'}  = %histo{'lines'};
    %histo{'histo'}{$c}{'last_col'}   = %histo{'col'};

    if (%histo{'histo'}{$c}{'count'} == 1) {
        %histo{'histo'}{$c}{'first_line'} = %histo{'lines'};
        %histo{'histo'}{$c}{'first_col'}  = %histo{'col'};
    }
        
    %histo{'col'}++;
    %histo{'total'}++;

    if $c eq "\n" {
        %histo{'lines'}++;
        %histo{'col'}=1;
    }
    
    %histo;
}


sub sayAlive(%spinner) {    
    if (%spinner{'count'} == %spinner{'limit'}) {
        print '.';
        %spinner{'count'} = 1;
    } else {
        %spinner{'count'}++;
    }
}


sub buildHistoFromFile(%histo, $filename) {
    my %spinner = 'count' => 1, 'limit' => 10000;
    my $in = open $filename, :r orelse .die;
    
    
    while defined $_ = $in.getc {
        addChar %histo, $_;
        sayAlive(%spinner);
    }
    say '';
        
    %histo;
}


sub sortKeys(%histo) {
    sort { 
          %histo{$^b}{'count'}      <=> %histo{$^a}{'count'}
       || %histo{$^a}{'first_line'} <=> %histo{$^b}{'first_line'}
       || %histo{$^a}{'first_col'}  <=> %histo{$^b}{'first_col'}
         }, %histo.keys;
}


sub printHeader {
    say 'count        character                  first(l,c)        last(l,c)';
    say '--------     -----------------          ----------        ---------';
}


sub printHisto(%histo, @keys) {

    for @keys {
    
        my $print = '';
           $print = $_ if /<print>/;
        my $num   = ord $_;
        my $count = %histo{$_}{'count'}; 
        my $first = sprintf "%d,%d", %histo{$_}{'first_line'}, %histo{$_}{'first_col'};
        my $last  = '';
           $last  = sprintf "%d,%d", %histo{$_}{'last_line'},  %histo{$_}{'last_col'} if $count > 1;


        say sprintf "%8d %5s %10d %-#13x %-10s        %-s", 
            $count,
            $print,
            $num,
            $num,
            $first,
            $last;
    }
}


sub printFooter(%histo) {
    say '----------------------------';
    say 'different characters: ' ~ %histo{'histo'}.elems;
    say 'total characters: ' ~ %histo{'total'};
    say 'total lines: ' ~ %histo{'lines'};
}


sub MAIN($file) {
    my %histo = buildHistoFromFile(initHisto, $file);
    
    printHeader;
    printHisto %histo{'histo'}, sortKeys %histo{'histo'};
    printFooter %histo;
}

