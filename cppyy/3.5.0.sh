set -e

pip uninstall -y cppyy cppyy-backend cppyy-cling CPyCppyy 2>/dev/null || true

if [[ "$(uname)" == "Darwin" ]]; then
  # ------------------------------------------------------------------ macOS
  # cppyy-cling 6.32.8 (LLVM/cling 16) cannot be built from source on macOS
  # with Xcode 16+ SDK (macOS 26.x) due to:
  #   1. cmake 4.x (pip build dep) breaks CMakeLists.txt:189
  #   2. Bundled zlib's fdopen macro conflicts with macOS 26.x _stdio.h
  # Use the pre-built binary wheel instead.
  echo "[cppyy] macOS: installing pre-built binary wheels..."
  pip install "cppyy=={{ version }}" \
      --no-cache-dir \
      --force-reinstall \
      --target {{ prefix }}

  PCH_DEST="{{ prefix }}/cppyy_backend/etc"
  LIBCLING="{{ prefix }}/cppyy_backend/lib/libCling.so"

  # ------------------------------------------------------------------
  # Fix MacPorts-linked libraries: the binary wheel was built on a system
  # with MacPorts and hardcodes /opt/local/lib paths.  Repoint them to
  # wherever libzstd actually lives on this machine (Homebrew or MacPorts).
  # ------------------------------------------------------------------
  if otool -L "$LIBCLING" 2>/dev/null | grep -q "/opt/local/lib/libzstd"; then
    if [ ! -f /opt/local/lib/libzstd.1.dylib ]; then
      LIBZSTD=$(ls /opt/homebrew/lib/libzstd.1.dylib /usr/local/lib/libzstd.1.dylib 2>/dev/null | head -1)
      if [ -n "$LIBZSTD" ]; then
        echo "[cppyy] Relinking libCling.so: /opt/local/lib/libzstd.1.dylib -> $LIBZSTD"
        install_name_tool -change /opt/local/lib/libzstd.1.dylib "$LIBZSTD" "$LIBCLING"
      else
        echo "[cppyy] WARNING: libzstd not found in Homebrew or /usr/local/lib."
        echo "[cppyy] Install it with: brew install zstd"
      fi
    fi
  fi

  # ------------------------------------------------------------------
  # PCH generation: cling 16 cannot parse macOS 26.x SDK headers.
  # Strategy: if an older macOS SDK (<=15.x) is available in the
  # Command Line Tools, point cling at it for PCH generation only.
  # The resulting PCH works for all subsequent cppyy usage.
  # ------------------------------------------------------------------
  if ! ls "$PCH_DEST"/allDict.cxx.pch.* 2>/dev/null | grep -q .; then
    OLD_SDK=$(ls -d /Library/Developer/CommandLineTools/SDKs/MacOSX15*.sdk \
                     /Library/Developer/CommandLineTools/SDKs/MacOSX14*.sdk \
                     /Library/Developer/CommandLineTools/SDKs/MacOSX13*.sdk \
              2>/dev/null | sort -V | tail -1)

    if [ -n "$OLD_SDK" ]; then
      SDK_VER=$(basename "$OLD_SDK" .sdk | sed 's/MacOSX//')
      echo "[cppyy] Building PCH using older SDK: $OLD_SDK"
      echo "[cppyy] (cling 16 is incompatible with macOS 26.x SDK headers)"
      SDKROOT="$OLD_SDK" MACOSX_DEPLOYMENT_TARGET="$SDK_VER" CLING_REBUILD_PCH=1 \
        PYTHONPATH={{ prefix }} python3 -c "import cppyy; print('[cppyy] PCH built with SDK', '$SDK_VER')"
      if ls "$PCH_DEST"/allDict.cxx.pch.* 2>/dev/null | grep -q .; then
        echo "[cppyy] PCH generated: $(ls $PCH_DEST/allDict.cxx.pch.*)"
      else
        echo "[cppyy] WARNING: PCH generation did not produce a file."
      fi
    else
      # No old SDK found — try if the system SDK somehow works (unlikely
      # with cling 16 + macOS 26.x but worth attempting).
      echo "[cppyy] No macOS 13/14/15 SDK found in CommandLineTools."
      echo "[cppyy] Attempting PCH generation with system SDK..."
      CLING_REBUILD_PCH=1 PYTHONPATH={{ prefix }} python3 -c "import cppyy" 2>&1 || true
      if ! ls "$PCH_DEST"/allDict.cxx.pch.* 2>/dev/null | grep -q .; then
        echo "[cppyy] -------------------------------------------------------"
        echo "[cppyy] FATAL: Cannot generate PCH. cling 16 in cppyy 3.5.0"
        echo "[cppyy] is incompatible with macOS 26.x SDK headers."
        echo "[cppyy]"
        echo "[cppyy] Fix options:"
        echo "[cppyy]  1. Ensure /Library/Developer/CommandLineTools/SDKs/"
        echo "[cppyy]     contains a MacOSX13.x, MacOSX14.x, or MacOSX15.x SDK."
        echo "[cppyy]  2. Copy a pre-built PCH from an existing working env:"
        echo "[cppyy]       cp <env>/lib/python*/site-packages/cppyy_backend/etc/allDict.cxx.pch.* \\"
        echo "[cppyy]          $PCH_DEST/"
        echo "[cppyy]  3. Wait for cppyy 3.6+ with LLVM 17+ support."
        echo "[cppyy] -------------------------------------------------------"
        exit 1
      fi
    fi
  else
    echo "[cppyy] PCH already present, skipping generation."
  fi

else
  # ------------------------------------------------------------------ Linux
  # Two-step source build to work around pip 26.x not propagating
  # PIP_CONSTRAINT into nested isolated build environments.
  # Step 1: pip wheel --no-build-isolation uses the venv's cmake<4 directly.
  # Step 2: pip install --find-links installs from the pre-built wheel.
  pip install setuptools wheel "cmake<4.0.0" --quiet

  if command -v g++ &>/dev/null; then
    export CXX=g++ CC=gcc
  fi
  echo "[cppyy] Compiler: $(${CXX:-c++} --version | head -1)"
  echo "[cppyy] cmake:    $(cmake --version | head -1)"

  echo "[cppyy] Building cppyy-cling wheel from source (~30-90 min)..."
  mkdir -p {{ builddir }}/cppyy-wheels
  STDCXX=17 MAKE_NPROCS={{ n_cores }} \
  pip wheel "cppyy-cling==6.32.8" \
      --no-binary cppyy-cling \
      --no-build-isolation \
      --no-cache-dir \
      --no-deps \
      -w {{ builddir }}/cppyy-wheels

  echo "[cppyy] Installing cppyy stack..."
  pip install "cppyy=={{ version }}" \
      --find-links {{ builddir }}/cppyy-wheels \
      --no-cache-dir \
      --force-reinstall \
      --target {{ prefix }}
fi

# ------------------------------------------------------------------ verify
# PYTHONPATH must include {{ prefix }} since packages land there, not site-packages.
PYTHONPATH={{ prefix }} python3 -c \
  "import cppyy, cppyy_backend, pathlib, sys; \
   base = pathlib.Path(cppyy_backend.__file__).parent / 'lib'; \
   lib = next((base / n for n in ('libCling.dylib', 'libCling.so') if (base / n).exists()), None); \
   print('[cppyy]', cppyy.__version__, '- libCling:', lib.name if lib else 'NOT FOUND'); \
   sys.exit(0 if lib else 1)"

echo "{{ version }}" > {{ prefix }}/.cppyy_install
echo "[cppyy] Done."
