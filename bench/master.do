cscript
discard
set more off
cd "d:\mijn documenten\projecten\stata\stdtable\1.1.0"
do bench\stdtable.do
do bench\string.do
do bench\subroutines.do
do bench\by.do
do bench\base.do
do bench\rowcol.do
exit
