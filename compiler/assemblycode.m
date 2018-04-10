STI 128, 10
LD R0, 128
SUBI R0, R0, 9
MULTI R1, R0, 4
ADDI R0, R1, 5
ST R0, 129
HLT


/* Variables are loaded at following locations:
b ->  128M 
a ->  129M 
*/