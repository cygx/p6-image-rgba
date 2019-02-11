PROVE = prove
PERL6 = perl6
RM = rm -rf
CHMOD-X = chmod -x

export PERL6LIB = lib

test:
	$(PROVE) -e '$(PERL6)' t

t-%: t/%-*.t
	$(PERL6) $<

.PHONY: examples
examples: 
	$(PERL6) examples/png.p6 examples/*.txt
	$(PERL6) examples/blending.p6 examples/blending.png
	@$(CHMOD-X) examples/*.png

clean:
	$(RM) examples/*.png
