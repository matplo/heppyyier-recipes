set -e
rm -rf fastjet-{{ version }}
git clone --depth 1 --branch fastjet-{{ version }} --recurse-submodules \
  https://gitlab.com/fastjet/fastjet.git fastjet-{{ version }}
cd fastjet-{{ version }}
NOCONFIGURE=1 ./autogen.sh
./configure --prefix={{ prefix }} {{ configure_args }}
make -j{{ n_cores }}
make install
