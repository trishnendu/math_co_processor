STI 128, 100
LDI R0, 0
SUBI R0, R0, 5
LD R1, 128
SUBI R1, R1, 10
MULTI R2, R1, 4
ADD R1, R0, R2
ST R1, 129
HLT


/* Variables are loaded at following locations:
b ->  128M 
a ->  129M 
*/