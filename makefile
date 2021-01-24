#For system install: export PREFIX=/usr/local/compiled
#For local $USER only:  export PREFIX=$(HOME)/.opt
export PREFIX=/usr/local/compiled

PYTHON3=$(PREFIX)/bin/python3
PERL=./perl.sh

all: $(PYTHON3)

$(PERL):
	curl https://www.cpan.org/src/ | sed -n '/^<pre>/,/^<\/pre>/ p' > $(PERL)
	sed -i -f bin/perl.sed perl.sh
	chmod +x $(PERL)

$(PREFIX)/lib/libz.so:
	./bin/git_build_install.sh

$(PYTHON3): $(PREFIX)/lib/libcrypto.so
	./bin/git_build_install.sh https://github.com/python/cpython.git

/usr/bin/python3: $(PYTHON3)
	sudo ln -fs $(PREFIX)/bin/python3 /usr/bin/python3

/usr/bin/pip3: $(PYTHON3)
	sudo ln -fs $(PREFIX)/bin/pip3 /usr/bin/pip3

$(PREFIX)/lib/libcrypto.so:
	./bin/openssl.sh

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
	./bin/openssl.sh $(PREFIX)

.PHONY: perl
perl: $(PERL)
	$(PERL)
	mv perl*.tar.gz ~/Downloads
	$(MAKE) -C perl*

.PHONY: python3
python3: $(PYTHON3) /usr/bin/python3 /usr/bin/pip3

.PHONY: junk
junk:
	./junk.sh
