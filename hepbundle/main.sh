set -e

echo "[hepbundle] Installing HEP software bundle..."
echo "[hepbundle] packages: fastjet fjcontrib hepmc3 lhapdf pythia8"
echo ""

heyy install fastjet
heyy install fjcontrib
heyy install hepmc3
heyy install lhapdf
heyy install pythia8

echo ""
echo "[hepbundle] Done."
