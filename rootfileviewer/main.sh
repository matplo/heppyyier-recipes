set -e

echo "[rootfileviewer] Installing from GitHub via SSH..."
pip install --upgrade git+ssh://git@github.com/matplo/rootfileviewer.git

echo "[rootfileviewer] Verifying install..."
python3 -c "import rootfileviewer; print('[rootfileviewer] OK:', rootfileviewer.__version__ if hasattr(rootfileviewer, '__version__') else 'installed')"

echo "[rootfileviewer] Done."
