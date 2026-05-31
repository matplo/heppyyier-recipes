# heppyyier-recipes

Recipe collection for [heppyyier](https://github.com/matplo/heppyyier) — a local HEP C++ package manager.

Recipes are automatically fetched when you run `heppyyier init`. To refresh:

```bash
heppyyier recipe update
```

## Available recipes

| Package | Version | Description |
|---------|---------|-------------|
| fastjet | 3.5.1 | Jet finding (FastJet) |
| fjcontrib | 1.102 | FastJet contrib — SoftDrop, Nsubjettiness, EnergyCorrelator |
| hepmc3 | 3.3.1 | HepMC3 event record I/O |
| jewel | 2.4.0 | JEWEL jet quenching event generator (requires lhapdf) |
| jewel | 2.2.0 | JEWEL jet quenching event generator (requires lhapdf) |
| lhapdf | 6.5.5 | LHAPDF6 PDF sets with Python (SWIG) bindings |
| lhapdf | 6.5.4 | LHAPDF6 PDF sets with Python (SWIG) bindings |
| pythia8 | 8.317 | Pythia8 event generator |

## Recipe format

Each recipe is a YAML file at `<name>/<version>.yaml`. See existing recipes for the format.
To contribute, open a pull request against this repository.
