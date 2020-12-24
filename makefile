export PREFIX=$(HOME)/.opt
PYTHON3=$(PREFIX)/bin/python3
PERL=./perl.sh

all: $(PYTHON3)

$(PERL):
	curl https://www.cpan.org/src/ | sed -n '/^<pre>/,/^<\/pre>/ p' > $(PERL)
	sed -i -f bin/perl.sed perl.sh
	chmod +x $(PERL)

$(PREFIX)/zlib:
	./bin/git_build_install.sh

$(PYTHON3): $(PREFIX)/zlib
	./bin/git_build_install.sh https://github.com/python/cpython.git
	echo "sudo ln -s $(PREFIX)/bin/python3 /usr/bin/python3"
	#sudo rm -f $(PREFIX)/bin/python3
	#mv $(PREFIX)/cpython $(PREFIX)

#
#   PHONY
#  T A R G E T
#
.PHONY: clean
clean:
	rm -rf perl.sh postgresql-* compiled.tar.xz
	cd python* && $(MAKE) clean && cd - >/dev/null

.PHONY: pkg
pkg:
	tar cf compiled.tar -C $(PREFIX)/.. ./compiled
	xz -f9 compiled.tar

.PHONY: distclean
distclean:
	rm -rf perl-* postgresql-* python-*
	rm -f perl.sh

.PHONY: git
git:
	./bin/download_build_install.sh https://mirrors.edge.kernel.org/pub/software/scm/git/

.PHONY: openssl
openssl:
	./bin/openssl.sh

.PHONY: perl
perl: $(PERL)
	$(PERL)
	mv perl*.tar.gz ~/Downloads
	$(MAKE) -C perl*

.PHONY: python3
python3:
	$(MAKE) $(PYTHON3)

.PHONY: junk
junk:
	./junk.sh
