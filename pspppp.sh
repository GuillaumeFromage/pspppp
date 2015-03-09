#!/bin/sh

cp asdf asdf.tmp
# TODO: convert in perl and expect a filename using GetOptions ?
# TODO: make a temporary directory (would be easier in perl)
INDEP="sexecat catage diplômecat blanchitude RecatPol"
DEP="ActionSupCat OpinionSupCat ReconnaissanceSupCat SupCat"
# TODO: this should default to all the variables.
DATA="p n dir"
# TODO: this should be parametrized

# first pass we just get all the tables to be generated at the end
for I in $DEP
do 
  for J in $INDEP
  do 
    # TODO: this is all wrong, if we run pspp -O format=csv, the output is ugly as butts but it does spews parsable CSV
    # would have been better to issue a sentinel here, but here's how PRINT does not work in SPSS. You can't "hello world".
    # sed -e "\$aPRINT / '$I versus $J'. " -i asdf.tmp
    # TODO: actually, there is an echo command...
    sed -e "\$aCROSSTABS /TABLES=$J BY $I /FORMAT=AVALUE TABLES PIVOT /STATISTICS=CHISQ /CELLS=COUNT TOTAL." -i asdf.tmp
  done ; 
done
 
cat asdf.tmp | pspp > asdf.tmp.out
csplit -sz asdf.tmp.out /Summary./ {*}
# TODO: tempdir ftw

COUNT=0;
PRETTYCOUNT=`printf %02d%s $COUNT`
X=O;
Y=0;
# we now have a fuck tonne of tiny files containing one chi2 each... lets fucking process
# the table header
# TODO: seriously, the output should be templatable. It would be sooooooooooooo easy to use HTML, Tex and Bash
# and use the damn perl format http://perldoc.perl.org/perlform.html
echo -en "|\t\t\t";
for A in $INDEP 
do 
  echo -en "| $A\t" ; 
done ; 
for I in $DEP
do 
  echo -en "|\n| $I\t\t";  
  for J in $INDEP
  do 
    for K in $DATA
    do 
      case $K in
        p) 
          P=`grep 'Pearson Chi-Square' "xx$PRETTYCOUNT" | cut -f 3 -d \| | tr -s '[:space:]' | tr -d \#` ;;
        n) 
          N=`grep 'N of Valid Cases' "xx$PRETTYCOUNT" | cut -f 3 -d \# | tr -d \| | tr -s '[:space:]'`  ;;
        dir) 
          # This is the direction of the correlation. It is this thing:
          # http://www.strath.ac.uk/aer/materials/4dataanalysisineducationalresearch/unit4/correlationsdirectionandstrength/

          # This one is real hard. I should have used a real programming language, so let's cheat.
          
          # at this point, we should just have had those values in the tables, and be able to extract the values to process the data 
          # to say "the direction is positive" ; but we don't, so lets get a new table w/ just the residual
          cat asdf | sed -e "\$aCROSSTABS /TABLES=$J BY $I /FORMAT=AVALUE TABLES PIVOT /STATISTICS=CHISQ /CELLS=RESIDUAL." | pspp > shitfucq
          # if we have only 2 values in total as an independant variable (otherwise, I'd have to find a statbook to figure
          # out how to calculate the fucking thing). That's because its not something I've figured out how to get from PSPP
          if (( $(cat shitfucq | grep -A 9 residual | grep -c Total) )) ; 
          then 
            # oh well, nice, we have a 4 entry table, with first line either -x, +x or +x, -x ; let's just check if the 
            # first number is above 0
            # TODO: when variable labels are too long, this get borked and spew some error messages from bc
            if (( $(echo "$(cat shitfucq | grep -A 6 residual | tail -n 1 | cut -d \# -f 3 | cut -d \| -f 1 | tr -s '[:space:]') > 0" | bc)  )) ;
            then 
              DIR='==>'; 
            else 
              DIR='<=='; 
            fi ;
          else 
            DIR='WTF'
          fi ;
          rm shitfucq
          
           ;;
      esac ;
    done ;
    # TODO: we need the option to print in green, red, yellow, if p<0.05, p>.10, 0.5<p<0.1 ; it needs to be compatible w/ less
    # so we can scroll horizontally
    # TODO: in html mode, it would be super easy to just toss the whole chi2 command output as an ajax crap
    echo -en "|p=$P;n=$N,$DIR\t" ;
    COUNT=$((COUNT+1))
    PRETTYCOUNT=`printf %02d%s $COUNT`
    X=$((X+1))
  done ;
  Y=$((Y+1))
done 
echo '|'
