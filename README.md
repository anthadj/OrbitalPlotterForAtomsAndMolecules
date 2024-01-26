# OrbitalPlotterForAtomsAndMolecules

This project plots orbitals of atoms and molecules using mathematica. Before using the code, the user needs to first run quantum mechanical calculations using the 
quantum chemistry package Molpro (https://www.molpro.net/) for the atom or molecule of interest. The user needs to specify to Molpro to dump the orbital information 
in a Molden file (https://www.theochem.ru.nl/molpro/molpro2006.1/doc/manual/node114.html). These molden files are then used as the input files of the code within this project. 

This project consists of two parts. First, two bash scripts that read information from atomic and molecular orbitals from a .molden file. The information is
is processed and thn stored in a .csv file format. 
Secondly, a mathematica script that reads information from the .csv file and plots the specified orbital of interest.

# Directory content:
src:
- `moldenscriptAtom.sh `
- `moldenscriptMolecule.sh`
- `ijkVals (directory)`
- `construct_wavefunction.nb`

inputs:  
- `h_1.molden`
- `c_222.molden`
- `ch4_22222.molden`

The src folder: 
Contains the two bash scripts "moldenscriptAtom.sh" and "moldenscriptMolecule.sh".
These two scripts are responsible for reading .molden files and rewriting the data in .csv format.
The first one is for atomic data and the second for molecular data. 
The ijkVals directory data necessary for the two afforementioned .sh scripts and souldn't be edited. 
The construct_wavefunction.nb is a mathematica script that reads the .csv file created from either .sh script and plots the orbitals.

The inputs folder:
Contains three example .molden files, two atomic cases (h_1.molden and c_222.molden) and one molecular (ch4_22222.molden).
The numbers in the names represent electrons in each orbital. Hydrogen only has 1 electron, while Carbon has 6 electrons residing
in 3 different orbitals. Methane (ch4) has 10 electrons residing in 10 orbitals. In this directoryhere place any .molden files 
you wish to analyse. 

# How to run the script:

Step 1 - Find the righ orbital:

The orbital of interest needs to be specified within the scripts
  
  For atomic script `moldenscriptAtom.sh`: 
    Just below the only TODO: find in the atomic script, line 38 contains the following `Awk '/ Sym=      1.1/,/ Sym=      2.1/  {print $2 }' ... `. This command finds the text that resides between lines `Sym=      1.1` and `Sym=      2.1`, which corresponds to the data necessary to plot orbital 1.1 (1s). If you wish to plot a different orbtal, change the number 1.1 and 2.1 with the right numbers. To find the right numbers, open h_1.molden and scrol down to where the orbital information is stored (that is when the [MO\] line appears). From that point onwards, every time the line " Sym=      " appears, it represents a different orbital. Find the orbital of interest, and the orbital that comes right after the orbital of interest from h_1.molden, i.e. if 1.3 is the orbital of interest, line 38 should become `Awk '/ Sym=      1.3/,/ Sym=      1.5/  {print $2 }' ... `. 
  
  For molecular script `moldenscriptMolecule.sh`: 
    Five amnual changes are needed, one for every TODO: in the file. 
    The first two are at the very top of the file, lines 9-24 and lines 28-30. The code right now works for ch4, with 5 atoms. It stores the position data of the five atoms in three txt files. For a molecule with a different number of atoms this needs to be adjusted. 
    The third change is the same as the atomic, where the orbital symmetry of interest and the orbital symmetry of the orbital right after the orbital of interest are spcified in line 47. 
    The fourth and fifth changes are in the two for loops in lines 72 and 126. The for loop occurs for all five atoms in the case of ch4. For a different molecule, the for loop needs to be adjusted for the correct number of atoms.
    

  
Step 2 - Running the bash scripts: 
For the atomic code use:
```
zsh moldenscriptAtom.sh ../inputs/<inputName>.molden
```

For the molecular code use:
```
zsh moldenscriptMolecule.sh ../inputs/<inputName>.molden
```

This will generate the necessary .csv file for the atom/molecule and specific orbital in question

Step 3 - Plotting the orbital:
Open `construct_wavefunction.nb` using mathematica. Run all lines to plot the orbital. 



# Contributions:
Special thanks is given to Dr. Mathew Peters for his contributions to this project

Further automations of the manual processes will be advantageous to the code. Any interested potential contributors or to report mistakes, please email antonis.hadjipittas@gmail.com 


