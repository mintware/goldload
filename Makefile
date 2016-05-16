# Use Borland Make >= 3.6

NASM = nasm
TLINK = tlink
PKZIP = pkzip
EHOPT = ehopt # comment out this line if ehopt isn't available on your system
META = http://sinil.in/mintware/goldenaxe/

prog = goldload.exe
dist = $(prog:.exe=.zip)
obj = goldload.obj

$(prog): $(obj)
	$(TLINK) /s @&&!
	$**
	$@
!
!if $d(EHOPT)
	$(EHOPT) $@ $*.opt "$(META)"
	del $@
	rename $*.opt $@
!endif

.asm.obj:
	$(NASM) -f obj -o $@ -l $&.lst $<

.exe.zip:
	$(PKZIP) $@ $<

dist: $(dist)

clean:
	del *.lst
	del *.obj
	del *.map
	del $(prog)
	del $(dist)
