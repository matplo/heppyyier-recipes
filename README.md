# heppyyier-recipes

Recipe collection for [heppyyier](https://github.com/matplo/heppyyier) — a local HEP C++ package manager.

Recipes are automatically fetched when you run `heppyyier init`. To refresh:

```bash
heppyyier recipe update
```

## Available recipes

| Package | Version | Description |
|---------|---------|-------------|
| dpmjet | 19.3.7 | DPMJET-III nucleus-nucleus / hadron-nucleus event generator (requires gfortran) |
| fastjet | 3.5.1 | Jet finding (FastJet) |
| fjcontrib | 1.102 | FastJet contrib — SoftDrop, Nsubjettiness, EnergyCorrelator |
| hepmc3 | 3.3.1 | HepMC3 event record I/O |
| jewel | 2.4.0 | JEWEL jet quenching event generator (requires lhapdf) |
| jewel | 2.2.0 | JEWEL jet quenching event generator (requires lhapdf) |
| lhapdf | 6.5.5 | LHAPDF6 PDF sets with Python (SWIG) bindings |
| lhapdf | 6.5.4 | LHAPDF6 PDF sets with Python (SWIG) bindings |
| powheg | v2 | POWHEG-BOX-V2 NLO event generator (requires svn; fetches source via SVN) |
| pythia8 | 8.317 | Pythia8 event generator |
| sherpa | 2.2.15 | Sherpa 2 multi-purpose event generator (optional: lhapdf, hepmc3, fastjet) |
| starlight | master | STARlight ultra-peripheral collision generator (optional: hepmc3, dpmjet) |

## Recipe format

Each recipe is a YAML file at `<name>/<version>.yaml`. See existing recipes for the format.
To contribute, open a pull request against this repository.
