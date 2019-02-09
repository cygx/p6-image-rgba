PROVE = prove
PERL6 = perl6
RM = rm -rf
CHMOD-X = chmod -x

export PERL6LIB = lib

test:
	$(PROVE) -e '$(PERL6)' t

t-%: t/%-*.t
	$(PERL6) $<

png: 
	$(PERL6) examples/png.p6 examples/*.txt
	@$(CHMOD-X) examples/*.png

clean:
	$(RM) examples/*.png
