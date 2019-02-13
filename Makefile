PROVE = prove
PERL6 = perl6
RM = rm -rf
CHMOD-X = chmod -x

NAME := Image-RGBA
VERSION := $(shell cat VERSION)
FULLNAME := $(NAME)-$(VERSION)
TARBALL := $(FULLNAME).tar.gz

export PERL6LIB = .6lib

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

dist: $(TARBALL)

upload: $(TARBALL)
	@perl6 -MCPAN::Uploader::Tiny -e 'CPAN::Uploader::Tiny.new(:user(prompt "user: "), :password(prompt "pass: ")).upload("$(TARBALL)")'

$(TARBALL): VERSION
	tar -T DIST.list --transform 's,^,$(FULLNAME)/,' -czf $@
