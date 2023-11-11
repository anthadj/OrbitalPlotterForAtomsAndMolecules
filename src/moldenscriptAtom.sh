#!/bin/zsh
#The format of the desired output file is as follows:
# i,j,k,primitive gaussian exponent (alpha), primitive gaussian weight,xnuc,ynuc,znuc,Contraction coefficeint (xnuc,ynuc,znuc is the position of the atom)
#this is all that is necessary to reconstruct the wavefunction. The molden uses contracted orbitals but it is much easier to read in the info into mathematica when the output file is a list of every single primitive gaussian rather than a list of contracted gaussians. Thus if the molden that is being read has contraction oribtals, then the contraction coefficients will be equivalent for all the primitives in that contracted orbital,
Rm ContractedCoeffs_Final.txt ijk_final.txt Exponent_Final.txt Weight_Final.txt $1.csv
#---Get info from Molden file---
#get positions of all the nuclei read in from the top of the molden file
#0.5291772106712 conversion form angstrong to AU
#H1x=$(($( awk ' NR==3 {print $4}' $1 )/0.5291772106712))
#H1y=$(($( awk ' NR==3 {print $5}' $1 )/0.5291772106712))
#H1z=$(($( awk ' NR==3 {print $6}' $1 )/0.5291772106712))
H1x=0
H1y=0
H1z=0
printf "$H1x\n" > x.txt
printf "$H1y\n" > y.txt
printf "$H1z\n" > z.txt



#copy the basis part of the molden to basis.txt
Awk '/\[Molden Format\]/,/\[MO\]/  {print $0}' $1 > basis.txt

#copy the contraction coefficeint part of the molden to orbitals.txt
sed -n -e '/\[MO\]/,$p' $1 > orbitals.txt

#get number of primitive s orbitals that makes up a contracted one.
#this will need to be big time changed if multiple contracted orbitals have more than one primitive gaussian

numcs=$(($(grep -n "s" $1 | sed -n 3p | awk '{print $1}' | sed -e 's/:.*//g')-7))

#echo $numcs
#exit

#grab the coefficient for a certain orbital energy, as ranged by 1.1 to 2.1 currently to get the lowest energy orbital
#TODO: Change depending on what orbital you want to calculate
Awk '/ Sym=      1.1/,/ Sym=      2.1/  {print $2 }' orbitals.txt > contractedCoeffsTemp.txt
sed -e '1,4d' < contractedCoeffsTemp.txt > ContractedCoeffs.txt
sed -i '' -e '$ d' ContractedCoeffs.txt

#divide by 3 since for me all the nuclei had the same total number of contraction coefficients, for CH4 will need to split into coefficients for C then 4X coefficients for H
#since I output a file with a list of all the primitives , I therefore need to reuse a contraction coefficient multiple times for all the primitives within it. So first find the number of primitives an orbital has, then figure out what contraction coefficient corresponds to it and then duplicate that coefficient as many times as there are primitives. E.g start with a vector of contraction coefficients {1,2,3,4}. If 1 corresponds to a contracted gaussian with 3 primitives then I need {1,1,1,2,3,4} as my vector.

#var=$(($(cat loworb1.txt | wc -l | xargs)/3)) #Not needed for atoms (for C and H).

#Split -l $var loworb1.txt #splits file x times, where x = $var
#head -1 xaa > temp1



#If line in "basis.txt" starts with " s" or " p" or " d" or " f", copy it into new file
awk '/^ s/||/^ p/||/^ d/||/^ f/||/^ g/' basis.txt > typeOfOrb_NumOfPrims.txt

#Separate further the TypeOfOrbs (s,p,d,f) from the NumOfPrims (number of primitives)
awk '{print $1}' TypeOfOrb_NumOfPrims.txt > TypeOfOrb_Final.txt #Final Form file
awk '{print $2}' TypeOfOrb_NumOfPrims.txt > NumOfPrims_Final.txt #Final Form file


#Copy all data in first(second) column from first line of "   1 0" to line [MO].
#Lines including " s" and [MO] are excluded
Awk '/   1 0/{flag=1;next}/[MO]/{flag=0}flag  {print $1 }' basis.txt > ExponentTemp.txt
Awk '/   1 0/{flag=1;next}/[MO]/{flag=0}flag  {print $2 }' basis.txt > WeightTemp.txt




#------Start working on Exponents and Weights of Primitives------
#Multiply exponents and weight depending on l-number depending on if it is s, p, d or f orbitals. s has l=0, p has l=1 and so on.
numOfEntries_Var=$(grep -c '' ExponentTemp.txt) #Number of Lines in file.
echo "numOfEntries_Var"
echo "$numOfEntries_Var"


i=1
echo "$i"
while [ $i -le $numOfEntries_Var ]
do
    data_orbType=$(sed $i'!d' ExponentTemp.txt) #Take data (line) from file
    data_PrimNum=$(sed $i'!d' WeightTemp.txt) #Take data (line) from file
    
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
                data_orbType_Print=$(sed $k'!d' ExponentTemp.txt) #Take data from file
                data_PrimNum_Print=$(sed $k'!d' WeightTemp.txt) #Take data from file
                
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



#------Start combining all data into one .csv file------
numOfPrims_Var=$(grep -c '' ContractedCoeffs_Final.txt) #Number of Lines in file. Representing number of Contracted Gaussians

echo "Writing Final Data"

for i in {1..$numOfPrims_Var}; do

    echo "$i"
    
    data_ijk=$(sed $i'!d' ijk_final.txt)
    data_primExp=$(sed $i'!d' Exponent_Final.txt)
    data_primWeigth=$(sed $i'!d' Weight_Final.txt)
    data_x=$(sed 1'!d' x.txt)
    data_y=$(sed 1'!d' y.txt)
    data_z=$(sed 1'!d' z.txt)
    data_contr=$(sed $i'!d' ContractedCoeffs_Final.txt)
    
    echo "$data_ijk,$data_primExp,$data_primWeigth,$data_x,$data_y,$data_z,$data_contr" >> $1.csv

done


#Changes all values from 1.23412D+02 to 1.23412E+02. This change allows mathematica to read the values
sed -E 's/([+-]?[0-9.]+)[D]\+?(-?)([0-9]+)/\1E\2\3/g' $1.csv > temp
grep -v  '0\.0$' temp > temp1
awk -F ',' '{if ($5 != "0.0000000000E00") print $0;}' temp1  > $1.csv

Rm temp temp1 contractedCoeffsTemp.txt WeightTemp.txt ExponentTemp.txt Exponent_Final.txt Weight_Final.txt x.txt y.txt z.txt basis.txt TypeOfOrb_Final.txt NumOfPrims_Final.txt typeOfOrb_NumOfPrims.txt ijk_final.txt ContractedCoeffs.txt ContractedCoeffs_Final.txt ijk_Final1.txt orbitals.txt

echo "Done"
