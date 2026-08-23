set -e
build_dir={{ srcdir }}-build
mkdir -p "$build_dir"
cd "$build_dir"
cmake_opts="-DCMAKE_INSTALL_PREFIX={{ prefix }} -DCMAKE_BUILD_TYPE=Release"
[ -n "{{ root_prefix }}" ] && cmake_opts="$cmake_opts -DCMAKE_PREFIX_PATH={{ root_prefix }}"
cmake {{ srcdir }} $cmake_opts
cmake --build . --target install -- -j{{ n_cores }}
