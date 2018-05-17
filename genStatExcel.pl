#!/usr/bin/env perl 
# ============================================================================ #
#                                                                              #
#         FILE: genStatExcel.pl                                                #
#                                                                              #
#        USAGE: ./genStatExcel.pl                                              #
#                                                                              #
#  DESCRIPTION: take x number of csv files                                     #
#             : generate one sheet per file with same name as file             #
#                                                                              #
#      OPTIONS: ---                                                            #
# REQUIREMENTS: ---                                                            #
#         BUGS: ---                                                            #
#        NOTES: ---                                                            #
#       AUTHOR: YOUR NAME (),                                                  #
# ORGANIZATION:                                                                #
#      VERSION: 1.0                                                            #
#      CREATED: 2018-04-19 15:25:58                                            #
#     REVISION: ---                                                            #
# ============================================================================ #

use Spreadsheet::WriteExcel;
use File::Basename;
use POSIX qw(strftime);
use utf8;

# -------------------------------------------------- #
#use strict;
#use warnings;
$pwd = `pwd`;
$pwd =~ s/^\s+|\s+$//g;
@types = ("dType", "extAuth", "norList", "gender");
my $file = "$pwd/departments.txt";
open my $info, $file or die "A Could not open $file: $!";
while( my $unitName = <$info>)  {   
    $unitName =~ s/^\s+|\s+$//g;
    print $unitName . "\n";    
    $workbook = Spreadsheet::WriteExcel->new("$pwd/result/$unitName.xls"); 
    for $type (@types) {
        # Do the thang
        chdir $type;

        $csv = "$unitName.csv";
        my $worksheet = $workbook->add_worksheet("$type");
        $csvfile = "$pwd/$type/$csv";
        open(FH,"<$csvfile") or die "B Cannot open $csvfile: $!\n";
        my ($x,$y) = (0,0);
        while (<FH>){ 
            chomp;
            @list = split /,/,$_;
            foreach my $c (@list){
                $worksheet->write($x, $y++, $c);     
            }
            $x++;$y=0;
        }

        chdir $pwd;
    }
    $workbook->close();
}

close $info;
exit;


$file  = $ARGV[0];
$unitName = $file;
$unitName =~ s{(.*)/}{};      # removes path  
$outputPath = $1;
chdir $outputPath;
my $workbook;
@files = @ARGV; 
for $file (@files) {
    #
    $unitName = $file;
    $unitName =~ s{(.*)/}{};      # removes path  
    $unitName =~ s{\.[^.]+$}{};        # removes extension
    $file =~s/^.*\///;
    
    #print "file:$file\n";
    #print "unitName:$unitName:\n";
    my $worksheet = $workbook->add_worksheet("$outputPath");    
    open(FH,"<$file") or die "Cannot open $file: $!\n";
    my ($x,$y) = (0,0);
    while (<FH>){ 
        chomp;
        @list = split /,/,$_;
        foreach my $c (@list){
            $worksheet->write($x, $y++, $c);     
        }
        $x++;$y=0;
    }
}
close(FH);
$workbook->close();

exit;
# -------------------------------------------------- #
$thisDate = strftime( '%x%X', localtime );
$excelOutFile = $thisDate  . '.xls';

$file  = $ARGV[0];
$unitName = $file;
$unitName =~ s{(.*)/}{};      # removes path  
$outputPath = $1;
chdir $outputPath;
my $workbook = Spreadsheet::WriteExcel->new("$excelOutFile"); 
@files = @ARGV; 
for $file (@files) {
    $unitName = $file;
    $unitName =~ s{(.*)/}{};      # removes path  
    $unitName =~ s{\.[^.]+$}{};        # removes extension
    $file =~s/^.*\///;
    print "file:$file\n";
    print "unitName:$unitName:\n";
    my $worksheet = $workbook->add_worksheet("$unitName");
    open(FH,"<$file") or die "Cannot open $file: $!\n";
    my ($x,$y) = (0,0);
    while (<FH>){ 
        chomp;
        @list = split /,/,$_;
        foreach my $c (@list){
            $worksheet->write($x, $y++, $c);     
        }
        $x++;$y=0;
    }
}
close(FH);
$workbook->close();
__END__
        ($name,$path,$suffix) = fileparse($fullname,@suffixlist);
        $name = fileparse($fullname,@suffixlist);
        $basename = basename($fullname,@suffixlist);
        $dirname  = dirname($fullname);;
