if [ ! -d tmp ]; then
	mkdir tmp
fi

for i in cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan aim65 sym1 w65c816sxb g65; do

echo $i
/opt/cc65/bin/ca65 -D $i -I /opt/cc65/asminc/ msbasic.s -o tmp/$i.o &&
/opt/cc65/bin/ld65 -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl

done

