<pre>
     wget <a href="https://www.cpan.org/src/5.0/perl-5.32.0.tar.gz">https://www.cpan.org/src/5.0/perl-5.32.0.tar.gz</a>
     tar -xzf perl-5.32.0.tar.gz
     cd perl-5.32.0
     ./Configure -des -Dprefix=$HOME/localperl
     make
     make test
     make install
</pre>
