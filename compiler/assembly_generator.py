import re

def allocreg():
    global regset
    for i in range(len(regset)):
        if regset[i]:   return i
    print("Out of registers :(")
    return -1


def isint(arg):
    return bool(re.match("^[0-9]+$", arg))

def simpleoperators(op, res, arg1, arg2):
    global tmptoreg, regset
    reg = allocreg()
    if reg == -1:   return 1

    if "tmp" not in arg1 and "tmp" not in arg2:
        if isint(arg1) and isint(arg2):
            outfile.write("LDI R"+str(reg)+", "+arg1+"\n")
            outfile.write(op+"I R"+str(reg)+", R"+str(reg)+", "+arg2+"\n")
        elif isint(arg1) and not isint(arg2):
            outfile.write("LD R"+str(reg)+", "+str(varopset+vartomem.index(arg2))+"\n")
            outfile.write(op+"I R"+str(reg)+", R"+str(reg)+", "+arg1+"\n")
        elif not isint(arg1) and isint(arg2):
            outfile.write("LD R"+str(reg)+", "+str(varopset+vartomem.index(arg1))+"\n")
            outfile.write(op+"I R"+str(reg)+", R"+str(reg)+", "+arg2+"\n")
        else:
            tmpreg = allocreg()
            outfile.write("LD R"+str(reg)+", "+str(varopset+vartomem.index(arg1))+"\n")
            outfile.write("LD R"+str(tmpreg)+", "+str(varopset+vartomem.index(arg2))+"\n")
            outfile.write(op+" R"+str(reg)+", R"+str(tmpreg)+", R"+str(reg)+"\n")
            regset[tmptoreg[tmpreg]] = True

    elif "tmp" in arg1 and "tmp" not in arg2:
        if isint(arg2):
            if arg1 not in intermidiatecode[curline+1: ]:   regset[tmptoreg[arg1]] = True   
            outfile.write(op+"I R"+str(reg)+", R"+str(tmptoreg[arg1])+", "+arg2+"\n")
        else:
            outfile.write("LD R"+str(reg)+", "+str(varopset+vartomem.index(arg2))+"\n")
            outfile.write(op+" R"+str(reg)+", R"+str(reg)+", "+arg1+"\n")

    elif "tmp" not in arg1 and "tmp" in arg2:
        if isint(arg1):
            if arg2 not in intermidiatecode[curline+1: ]:   regset[tmptoreg[arg2]] = True
            outfile.write(op+"I R"+str(reg)+", R"+str(tmptoreg[arg2])+", "+arg1+"\n")
        else:
            outfile.write("LD R"+str(reg)+", "+str(varopset+vartomem.index(arg1))+"\n")
            outfile.write(op+" R"+str(reg)+", R"+str(reg)+", "+arg2+"\n")

    else:
        outfile.write(op+" R"+str(reg)+", R"+str(tmptoreg[arg1])+", R"+str(tmptoreg[arg2])+"\n")
        if arg1 not in intermidiatecode[curline+1: ]:   regset[tmptoreg[arg1]] = True
        if arg2 not in intermidiatecode[curline+1: ]:   regset[tmptoreg[arg2]] = True
        
    tmptoreg[res] = reg
    regset[reg] = False
    return 0
    

def memoperator(res, arg):
    if isint(arg):
        outfile.write("STI "+str(varopset+vartomem.index(res))+", "+arg+"\n")
    elif "tmp" in arg:
        outfile.write("ST R"+str(tmptoreg[arg])+", "+str(varopset+vartomem.index(res))+"\n")
    else:
        tmpreg = allocreg()
        outfile.write("LD R"+str(tmpreg)+", "+str(varopset+vartomem.index(arg))+"\n")
        outfile.write("ST "+arg+", "+str(varopset+vartomem.index(res))+"\n")
        regset[tmptoreg[tmpreg]] = True


regset = [True for n in range(16)]
tmptoreg = {}
vartomem = []
varopset = 128
inputfile = open('threeaddresscode.txt')
outfile = open('assemblycode.m','w')
intermidiatecode = inputfile.read().split("\r\n")
#print((len(intermidiatecode), intermidiatecode[0]))
curline = 0
flag = True
while True:
    if "end" in intermidiatecode[curline]:  
        outfile.write("HLT\n")
        break
    print((curline,intermidiatecode[curline]))
    op, res, arg1, arg2 = intermidiatecode[curline].split(",")
    val = 0 
    if "+" in op:   val = simpleoperators("ADD", res, arg1, arg2)
    elif "-" in op:   val = simpleoperators("SUB", res, arg1, arg2)
    elif "*" in op:   val = simpleoperators("MULT", res, arg1, arg2)
    elif "/" in op:   val = simpleoperators("DIV", res, arg1, arg2)
    elif "=" in op:
        if res not in vartomem: vartomem.append(res)
        val = memoperator(res, arg2)      
    else:   outfile.write(op+" "+res+"\n")
    if(val):    break
    curline += 1
outfile.write("\n\n/* Variables are loaded at following locations:\n")
for i in range(len(vartomem)):
    outfile.write(vartomem[i]+" ->  "+str(i+varopset)+"M \n")
outfile.write("*/")
outfile.close()