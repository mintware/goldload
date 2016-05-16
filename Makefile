# Use Borland Make >= 3.6

NASM = nasm
PKZIP = pkzip

prog = goldload.com
dist = $(prog:.com=.zip)

$(prog):

.asm.com:
	$(NASM) -f bin -o $@ -l $&.lst $<

.com.zip:
	$(PKZIP) $@ $<

dist: $(dist)

clean:
	del *.lst
	del $(prog)
	del $(dist)
