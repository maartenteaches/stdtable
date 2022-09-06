cscript
discard
set more off
cd "d:\mijn documenten\projecten\stata\stdtable\"
do bench\stdtable.do
do bench\string.do
do bench\subroutines.do
do bench\by.do
do bench\base.do
do bench\rowcol.do
if c(stata_version) >= 16 {
	do bench\frame.do
}
exit
