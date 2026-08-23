set -e
./configure --prefix={{ prefix }} --without-alllang --with-python
make -j{{ n_cores }}
make install
