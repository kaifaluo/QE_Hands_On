#!/bin/bash -l
# src=$BGW_TUTORIAL/1-silicon_gw-run
src=/work2/06868/giustino/EP-SCHOOL/BGW/internal/1-silicon_gw-run/

# ln -sf $src/1-mf-qe/1-scf/CD .
# ln -sf $src/1-mf-qe/1-scf/Si_POT.DAT .
mkdir -p Si.save
ln -sf $src/1-mf-qe/1-scf/Si.save/charge-density.dat Si.save/
ln -sf $src/1-mf-qe/1-scf/Si.save/data-file.xml Si.save/
ln -sf $src/1-mf-qe/1-scf/Si.save/data-file-schema.xml Si.save/
ln -sf $src/1-mf-qe/1-scf/Si.UPF .
