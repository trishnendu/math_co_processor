def inttohex(val):
	return hex(int(val))[2:]

instruction_code = {"NOP":"0", "HLT":"1", "LDPC":"2", "MV":"3",
					"LD":"4", "LDI":"5", "ST":"6", "STI":"7",
					"ADD":"8", "ADDI":"9", "SUB":"A", "SUBI":"B",
					"MULT":"C", "MULTI":"D", "DIV":"E", "DIVI":"F"}

inputfile = open('assemblycode.m')
outfile = open('programed_rom.mem','w')
outline = 0
assemblycode = inputfile.read().split("\n")
curline = 0
while True: 
	if "HLT" in assemblycode[curline]:
		outfile.write(instruction_code["HLT"]+"xxx"+"\n"+"xxxx\n"*(256-outline-1))  
		break
	args = assemblycode[curline].replace(",","").split(" ")
	print((curline,args))
	outfile.write(instruction_code[args[0]])
	if int(instruction_code[args[0]], 16) % 2:
		if args[0] == "MV":
			outfile.write(inttohex(args[i].replace("R",""))+inttohex(args[i].replace("R",""))+"x\n")
			outline += 1
		else:
			if int(instruction_code[args[0]], 16) > 8:
				outfile.write(inttohex(args[1].replace("R",""))+inttohex(args[2].replace("R",""))+"x\n")
				outline += 1	
			elif args[0] == "LDI":
				outfile.write(inttohex(args[1].replace("R",""))+"xx\n")
				outline += 1
			elif args[0] == "STI":
				outfile.write("x"+inttohex(args[1])+"\n")
				outline += 1
			const = inttohex(args[-1])
			outfile.write("0"*(4-len(const))+const+"\n")
			outline += 1
	else:
		for i in range(1, len(args)):
			if "R" in args[i]:
				outfile.write(inttohex(args[i].replace("R","")))
			else:
				outfile.write(inttohex(args[i]))
		outfile.write("\n")
		outline += 1
	curline += 1
outfile.close()

	