#For system install: export PREFIX=/usr/local/compiled
#For local $USER only:  export PREFIX=$(HOME)/.opt
export PREFIX=/usr/local/compiled

PERL=./perl.sh
PYPA=$(PREFIX)/share/pypa
PYTHON3=$(PREFIX)/bin/python3

all: $(PYTHON3)

$(PERL):
	curl https://www.cpan.org/src/ | sed -n '/^<pre>/,/^<\/pre>/ p' > $(PERL)
	sed -i -f bin/perl.sed perl.sh
	chmod +x $(PERL)

$(PREFIX)/lib/libz.so:
	./bin/git_build_install.sh

$(PYTHON3): $(PREFIX)/lib/libcrypto.so
	./bin/git_build_install.sh https://github.com/python/cpython.git

pypa/requirements.txt: requirements.txt
	pip3 install wheel
	mkdir -p ./pypa
	cp requirements.txt ./pypa
	cd ./pypa && $(PREFIX)/bin/pip3 download -r ./requirements.txt
	cd ./pypa && $(PREFIX)/bin/pip3 wheel *.gz

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
	rm -rf perl.sh postgresql-* compiled.tar.xz ./pypa
	cd python* && $(MAKE) clean && cd - >/dev/null

.PHONY: pkg
pkg:	# first two lines attempt command for local installs. On failure execute commands using sudo.
	mkdir -p $(PYPA) || sudo mkdir -p $(PYPA)
	cp ./pypa/requirements.txt ./pypa/*.whl $(PYPA) || sudo cp ./pypa/requirements.txt ./pypa/*.whl $(PYPA)
	tar cf compiled.tar -C $(PREFIX)/.. ./compiled
	xz -f9 compiled.tar

.PHONY: distclean
distclean:
	ls ./ | sed '/bin/d ; /makefile/d ; /requirements.txt/d' | xargs rm -rf

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
python3: $(PYTHON3) /usr/bin/python3 /usr/bin/pip3 pypa/requirements.txt

.PHONY: junk
junk:
	./junk.sh
