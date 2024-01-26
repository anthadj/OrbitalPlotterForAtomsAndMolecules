#!/bin/zsh
#The format of the desired output file is as follows:
# i,j,k,primitive gaussian exponent (alpha), primitive gaussian weight,xnuc,ynuc,znuc,Contraction coefficeint (xnuc,ynuc,znuc is the position of the atom)
#this is all that is necessary to reconstruct the wavefunction. The molden uses contracted orbitals but it is much easier to read in the info into mathematica when the output file is a list of every single primitive gaussian rather than a list of contracted gaussians. Thus if the molden that is being read has contraction oribtals, then the contraction coefficients will be equivalent for all the primitives in that contracted orbital,
Rm ContractedCoeffs_Final.txt ijk_final.txt Exponent_Final.txt Weight_Final.txt $1.csv x.txt y.txt z.txt
#---Get info from Molden file---
#get positions of all the nuclei read in from the top of the molden file
#0.5291772106712 conversion form angstrong to AU
#TODO: Add or remove lines depending on number of atoms in molecule.
C1x=$(($( awk ' NR==3 {print $4}' $1 )/0.5291772106712))
C1y=$(($( awk ' NR==3 {print $5}' $1 )/0.5291772106712))
C1z=$(($( awk ' NR==3 {print $6}' $1 )/0.5291772106712))
H1x=$(($( awk ' NR==4 {print $4}' $1 )/0.5291772106712))
H1y=$(($( awk ' NR==4 {print $5}' $1 )/0.5291772106712))
H1z=$(($( awk ' NR==4 {print $6}' $1 )/0.5291772106712))
H2x=$(($( awk ' NR==5 {print $4}' $1 )/0.5291772106712))
H2y=$(($( awk ' NR==5 {print $5}' $1 )/0.5291772106712))
H2z=$(($( awk ' NR==5 {print $6}' $1 )/0.5291772106712))
H3x=$(($( awk ' NR==6 {print $4}' $1 )/0.5291772106712))
H3y=$(($( awk ' NR==6 {print $5}' $1 )/0.5291772106712))
H3z=$(($( awk ' NR==6 {print $6}' $1 )/0.5291772106712))
H4x=$(($( awk ' NR==7 {print $4}' $1 )/0.5291772106712))
H4y=$(($( awk ' NR==7 {print $5}' $1 )/0.5291772106712))
H4z=$(($( awk ' NR==7 {print $6}' $1 )/0.5291772106712))

#print x,y,z position to file for each nuclei
#TODO: Add or remove depending on number of atoms in molecule
printf "$C1x\n$H1x\n$H2x\n$H3x\n$H4x\n" > x_initial.txt
printf "$C1y\n$H1y\n$H2y\n$H3y\n$H4y\n" > y_initial.txt
printf "$C1z\n$H1z\n$H2z\n$H3z\n$H4z\n" > z_initial.txt




#copy the basis part of the molden to basis.txt
Awk '/\[Molden Format\]/,/\[MO\]/  {print $0}' $1 > basis.txt

#copy the contraction coefficeint part of the molden to orbitals.txt
sed -n -e '/\[MO\]/,$p' $1 > orbitals.txt

#get number of primitive s orbitals that makes up a contracted one.
#this will need to be big time changed if multiple contracted orbitals have more than one primitive gaussian
numcs=$(($(grep -n "s" $1 | sed -n 3p | awk '{print $1}' | sed -e 's/:.*//g')-7))

#grab the coefficient for a certain orbital energy, as ranged by 1.1 to 2.1 currently to get the lowest energy orbital
#TODO: Change values, depending on what orbital you want to plot. eg. to plot orbital 1.1: Awk '/ Sym=      1.1/,/ Sym=      1.1/ ... for 2.1 Awk '/ Sym=      2.1/,/ Sym=      3.1/ etc
Awk '/ Sym=      1.1/,/ Sym=      2.1/  {print $2 }' orbitals.txt > contractedCoeffsTemp.txt
sed -e '1,4d' < contractedCoeffsTemp.txt > ContractedCoeffs.txt
sed -i '' -e '$ d' ContractedCoeffs.txt

#divide by 3 since for me all the nuclei had the same total number of contraction coefficients, for CH4 will need to split into coefficients for C then 4X coefficients for H
#since I output a file with a list of all the primitives , I therefore need to reuse a contraction coefficient multiple times for all the primitives within it. So first find the number of primitives an orbital has, then figure out what contraction coefficient corresponds to it and then duplicate that coefficient as many times as there are primitives. E.g start with a vector of contraction coefficients {1,2,3,4}. If 1 corresponds to a contracted gaussian with 3 primitives then I need {1,1,1,2,3,4} as my vector.

#var=$(($(cat loworb1.txt | wc -l | xargs)/3)) #Not needed for atoms (for C and H).




#If line in "basis.txt" starts with " s" or " p" or " d" or " f", copy it into new file
awk '/^ s/||/^ p/||/^ d/||/^ f/||/^ g/' basis.txt > typeOfOrb_NumOfPrims.txt

#Separate further the TypeOfOrbs (s,p,d,f) from the NumOfPrims (number of primitives)
awk '{print $1}' TypeOfOrb_NumOfPrims.txt > TypeOfOrb_Final.txt #Final Form file
awk '{print $2}' TypeOfOrb_NumOfPrims.txt > NumOfPrims_Final.txt #Final Form file


#Copy all data in first(second) column from first line of "   1 0" to line [MO].
#Lines including " s" and [MO] are excluded
Awk '/[GTO]/{flag=1;next}/[MO]/{flag=0}flag  {print $1 }' basis.txt > ExponentTemp.txt
Awk '/[GTO]/{flag=1;next}/[MO]/{flag=0}flag  {print $2 }' basis.txt > WeightTemp.txt

#TODO: Change for loop number depending on number of atoms present. If number of atoms are 5, loop should go from 1 to 5
Rm Exponents_Together.txt Weights_Together.txt
linesToCopy_start=1
for i in {1..5}; do
    j=$(( i+1 ))
    
    expoName=ExponentTemp_$i.txt
    weightName=WeightTemp_$i.txt

    #Copy Exponents of each atom
    sed -n -e '/'"^$i"'/,/'"^$j"'/p' ExponentTemp.txt > $expoName
    
    #Find number of lines in newly created file with exponents for atoms, to use later in how many lines to copy for weights.
    increaseLinesToCopy=$(grep -c '' $expoName) #Number of Lines in file.
    linesToCopy_end=$((linesToCopy_start+increaseLinesToCopy))
    
    num_use_start=$((linesToCopy_start+1))
    num_use_end=$((linesToCopy_end-2))
        
    #Copy weights of each atom based on number of lines found before
    sed -n ''$num_use_start','$num_use_end'p' WeightTemp.txt > $weightName
    
    #grep -v '^s\|^p\|^d\|^f' $expoName > out.txt
    #sed '/^\$5$/d' $weightName > ini.txt #Removes all lines that only have 0

    linesToCopy_start=$((linesToCopy_end-1))
    
    #---Start removal of first and last line in all Exponential files---
    newExpoName=$expoName.temp
    newExpoName2=$expoName.temp2
    
    cp $expoName $newExpoName
    sed '$ d' $newExpoName > $newExpoName2
    sed '1,1d' $newExpoName2  > $expoName
    rm -f $newExpoName $newExpoName2
    #---Finished removing first and last lines---
    
    #Combine all data from 5 atoms into 1 file for exponents and weights
    cat "$expoName" >> Exponents_Together.txt
    cat "$weightName" >> Weights_Together.txt
done

#Remove empty lines from the two files
cp Exponents_Together.txt Exponents_Together_2.txt
cp Weights_Together.txt Weights_Together_2.txt
sed '/^$/d' Exponents_Together_2.txt > Exponents_Together.txt #Remove empty lines
sed '/^$/d' Weights_Together_2.txt > Weights_Together.txt #Remove empty lines
rm -f Weights_Together_2.txt Exponents_Together_2.txt


#------Adjust position files------
#Position files need to be equal to total number of primitive Gaussians present
#Also each position must be corresponding to the right atom!
#To achieve this,
#TODO: Change for loop number depending on number of atoms present. If number of atoms are 5, loop should go from 1 to 5
for i in {1..5}; do
    
    expoName=ExponentTemp_$i.txt
    weightName=WeightTemp_$i.txt
    
    numOfEntries_Var=$(grep -c '' $expoName) #Number of Lines in file.
    
    totalMultiplications=0
    for j in {1..$numOfEntries_Var}; do

        data_orbType=$(sed $j'!d' $expoName) #Take data (line) from file
        data_PrimNum=$(sed $j'!d' $weightName) #Take data (line) from file
        
        if [ "$data_orbType" = "s" ] || [ "$data_orbType" = "p" ] || [ "$data_orbType" = 'd' ] || [ "$data_orbType" = 'f' ] || [ "$data_orbType" = 'g' ];
        then
        
            if [ "$data_orbType" = 's' ]; then iterations_lcontrib=1
            elif [ "$data_orbType" = 'p' ]; then iterations_lcontrib=3
            elif [ "$data_orbType" = 'd' ]; then iterations_lcontrib=6
            elif [ "$data_orbType" = 'f' ]; then iterations_lcontrib=10
            elif [ "$data_orbType" = 'g' ]; then iterations_lcontrib=15
            fi
        
            timesToMultiply=$((iterations_lcontrib*data_PrimNum))
            
            #echo "timesToMultiply"
            #echo "$timesToMultiply"
            
            #Total number to multiply position of an atom
            totalMultiplications=$((totalMultiplications+timesToMultiply))
        fi
    done
    
    Xdata=$(sed $i'!d' x_initial.txt) #Take data from file
    Ydata=$(sed $i'!d' y_initial.txt) #Take data from file
    Zdata=$(sed $i'!d' z_initial.txt) #Take data from file
    
    for k in {1..$totalMultiplications}; do
        echo "$Xdata" >> x.txt #Final output file for x
        echo "$Ydata" >> y.txt #Final output file for x
        echo "$Zdata" >> z.txt #Final output file for x
    done
    
    rm $expoName $weightName
    
done
rm x_initial.txt y_initial.txt z_initial.txt
#------Finished adjusting position files------
    




#------Start working on Exponents and Weights of Primitives------
#Multiply exponents and weight depending on l-number depending on if it is s, p, d or f orbitals. s has l=0, p has l=1 and so on.
numOfEntries_Var=$(grep -c '' Exponents_Together.txt) #Number of Lines in file.
echo "numOfEntries_Var"
echo "$numOfEntries_Var"


i=1
echo "$i"
while [ $i -le $numOfEntries_Var ]
do
    data_orbType=$(sed $i'!d' Exponents_Together.txt) #Take data (line) from file
    data_PrimNum=$(sed $i'!d' Weights_Together.txt) #Take data (line) from file
    
    #echo "i: "
    #echo "$i"
    #echo "data_orbType: "
    #echo "$data_orbType"
    #echo "data_PrimNum: "
    #echo "$data_PrimNum"

    #If line in file ExponentTemp.txt has p, d or f do following:
    if [ "$data_orbType" = "s" ] || [ "$data_orbType" = "p" ] || [ "$data_orbType" = 'd' ] || [ "$data_orbType" = 'f' ]|| [ "$data_orbType" = 'g' ];
    then
    
        if [ "$data_orbType" = 's' ]; then iterations=1
        elif [ "$data_orbType" = 'p' ]; then iterations=3
        elif [ "$data_orbType" = 'd' ]; then iterations=6
        elif [ "$data_orbType" = 'f' ]; then iterations=10
    elif [ "$data_orbType" = 'g' ]; then iterations=15
        fi
        
        numStart=$((i+1))
        numEnd=$((i+data_PrimNum))
        
        #echo "---------------------------------------------"
        #echo "Numstart and numend: "
        #echo "$numStart"
        #echo "$numEnd"
        #echo ""
        
        for j in {1..$iterations}; do
        
            #echo "j and primnum"
            #echo "$j"
            #echo "$data_PrimNum"
            
            for k in {$numStart..$numEnd}; do
                data_orbType_Print=$(sed $k'!d' Exponents_Together.txt) #Take data from file
                data_PrimNum_Print=$(sed $k'!d' Weights_Together.txt) #Take data from file
                
                #echo "data1 and 2: "
                #echo "$data_orbType_Print"
                #echo "$data_PrimNum_Print"
                
                #echo ""
                echo "$data_orbType_Print" >> Exponent_Final.txt
                echo "$data_PrimNum_Print" >> Weight_Final.txt
            done
        done
        
        i=$((numEnd+1))
        #echo "new i:"
        #echo "$i"
    else
        i=$(( i+1 ))
    fi
    #echo ""
    #echo ""
done
#------Finished working on exponents and weights------



#------Start altering Contracted Coefficients:------
((contCoeffs_Var=1))
numOfPrims_Var=$(grep -c '' NumOfPrims_Final.txt) #Number of Lines in file. Representing number of Contracted Gaussians
#echo "$numOfPrims_Var"

for i in {1..$numOfPrims_Var}; do
    
    #------Take Initial Necessary Data------
    orbType_Var=$(sed $i'!d' TypeOfOrb_Final.txt) #Take data from file TypeOfOrb_Final.txt
    primsInContracted_Var=$(sed $i'!d' NumOfPrims_Final.txt) #Take data from file NumOfPrims_Final.txt
    #------End------
    
    #echo "$primsInContracted_Var"
    
    
    #------Writes i,j,k data to file------
    
        #Final output file - Copying i, j and k for each corresponding contracted Gaussian coefficient
    echo $psym1
    if [ "$orbType_Var" = 's' ]; then awk -v j="$primsInContracted_Var" '{for(i=0; i<j; i++)print}' ijkVals/ijk0.txt > ijk_Final1.txt
    elif [ "$orbType_Var" = 'p' ]; then awk -v j="$primsInContracted_Var" '{for(i=0; i<j; i++)print}' ijkVals/ijk1.txt > ijk_Final1.txt
    elif [ "$orbType_Var" = 'd' ]; then awk -v j="$primsInContracted_Var" '{for(i=0; i<j; i++)print}' ijkVals/ijk2.txt > ijk_Final1.txt
    elif [ "$orbType_Var" = 'f' ]; then awk -v j="$primsInContracted_Var" '{for(i=0; i<j; i++)print}' ijkVals/ijk3.txt > ijk_Final1.txt
    elif [ "$orbType_Var" = 'g' ]; then awk -v j="$primsInContracted_Var" '{for(i=0; i<j; i++)print}' ijkVals/ijk4.txt > ijk_Final1.txt
        fi
    cat ijk_Final1.txt >> ijk_Final.txt
    #------End------
    
    
    #------Start Altering Contracted Coeffs------
    ((contCoeffs_Before_Var=contCoeffs_Var))
    
    if [ "$orbType_Var" = 's' ]; then ((contCoeffs_Var += 1))
    elif [ "$orbType_Var" = 'p' ]; then ((contCoeffs_Var+=3))
    elif [ "$orbType_Var" = 'd' ]; then ((contCoeffs_Var+=6))
    elif [ "$orbType_Var" = 'f' ]; then ((contCoeffs_Var+=10))
    elif [ "$orbType_Var" = 'g' ]; then ((contCoeffs_Var+=15))  fi
        
    for ((j=contCoeffs_Before_Var; j<contCoeffs_Var; j++)); do
        dataToCopy=$(sed $j'!d' ContractedCoeffs.txt)   #Taking line to multiply
        
        for ((i=0;i<primsInContracted_Var;i++)); do #Writes data to file as many times as it must
            echo "$dataToCopy" >> ContractedCoeffs_Final.txt #Final output file - Copying contracted Gaussian Coeffictients
        done
    done
    #------End------
    
    #echo "$orbType_Var"
    #echo "$primsInContracted_Var"
    #echo "$contCoeffs_Before_Var"
    #echo "$contCoeffs_Var"
done
#------End altering contracted coefficients



#------Start combining all data into one .csv file------
numOfPrims_Var=$(grep -c '' ContractedCoeffs_Final.txt) #Number of Lines in file. Representing number of Contracted Gaussians

echo "Writing Final Data"
for i in {1..$numOfPrims_Var}; do

    #echo "$i"
    
    data_ijk=$(sed $i'!d' ijk_final.txt)
    data_primExp=$(sed $i'!d' Exponent_Final.txt)
    data_primWeigth=$(sed $i'!d' Weight_Final.txt)
    data_x=$(sed $i'!d' x.txt)
    data_y=$(sed $i'!d' y.txt)
    data_z=$(sed $i'!d' z.txt)
    data_contr=$(sed $i'!d' ContractedCoeffs_Final.txt)
    
    echo "$data_ijk,$data_primExp,$data_primWeigth,$data_x,$data_y,$data_z,$data_contr" >> $1.csv

done


#Changes all values from 1.23412D+02 to 1.23412E+02. This change allows mathematica to read the values
sed -E 's/([+-]?[0-9.]+)[D]\+?(-?)([0-9]+)/\1E\2\3/g' $1.csv > temp
awk -F ',' '{if ($9 != "0\.0") print $0;}' temp  > temp1
awk -F ',' '{if ($5 != "0\.0000000000E00") print $0;}' temp1  > $1.csv



Rm ContractedCoeffs_Final.txt ijk_final.txt Exponent_Final.txt Weight_Final.txt x.txt y.txt z.txt basis.txt orbitals.txt contractedCoeffsTemp.txt typeOfOrb_NumOfPrims.txt TypeOfOrb_Final.txt NumOfPrims_Final.txt ExponentTemp.txt WeightTemp.txt Exponents_Together.txt Weights_Together.txt ijk_Final1.txt ContractedCoeffs.txt temp temp1

echo "Done"

