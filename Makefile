TARGETS = plancklisp
OBJECTS=eval.o read.o write.o main.o

%.o:	%.asm
	nasm -f elf64 -o $@ $<

all:	$(TARGETS)

plancklisp:	$(OBJECTS)
	ld -s -o $@ $^

main.o:		main.asm macro.inc
eval.o:		eval.asm macro.inc
read.o:		read.asm macro.inc
write.o:	write.asm macro.inc

clean:
	rm $(TARGETS) $(OBJECTS)

