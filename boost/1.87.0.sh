set -e
version_us=$(echo "{{ version }}" | tr '.' '_')
tarball="boost_${version_us}.tar.gz"
url="https://archives.boost.io/release/{{ version }}/source/$tarball"
echo "[boost] downloading $url"
curl -sL "$url" -o "$tarball"
tar xzf "$tarball"
cd "boost_${version_us}"
./bootstrap.sh --prefix={{ prefix }}
./b2 -j{{ n_cores }} install --prefix={{ prefix }} --build-dir={{ srcdir }}/boost-build
