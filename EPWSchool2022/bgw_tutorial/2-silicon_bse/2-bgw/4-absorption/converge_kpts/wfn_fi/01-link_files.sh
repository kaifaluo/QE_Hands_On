#!/bin/bash -l

# ln -sf ../../../../1-mf/1-scf/Si_POT.DAT .
# ln -sf ../../../../1-mf/1-scf/CD .
mkdir -p Si.save
ln -sf ../../../../../1-mf/1-scf/Si.save/charge-density.dat Si.save/
ln -sf ../../../../../1-mf/1-scf/Si.save/data-file.xml Si.save/
ln -sf ../../../../../1-mf/1-scf/Si.save/data-file-schema.xml Si.save/
ln -sf ../../../../1-mf/1-scf/Si.UPF .
