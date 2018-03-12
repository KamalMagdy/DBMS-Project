#!/bin/bash

USEDB_FLAG=0
DB_NAME=""

function showDBs(){
  if [[ "${arr[0]}" = "show" && "${arr[1]}" = "databases" ]]; then
    ls -d */
  else
    echo "Syntax error!"
  fi
}

#######################################
function createDBsTb(){
  if [[ "${arr[0]}" = "create" && "${arr[1]}" = "database" ]]; then       #create database
    echo "Creating ..."
    sleep 1
    if [ -d "${arr[2]}" ]; then
      echo "Database ${arr[2]} already exist!"
    else
      mkdir "${arr[2]}"
      echo "Database ${arr[2]} created successfully"
    fi
  elif [[ "${arr[0]}" = "create" && "${arr[1]}" = "table" ]]; then
    if (( $USEDB_FLAG )); then
      tableName="${arr[2]}"
      if [ -f ./$DB_NAME/$tableName.table ]; then
        echo "Table ${arr[2]} already exist!"
      else
        touch ./$DB_NAME/$tableName.table
        touch ./$DB_NAME/$tableName.cons  #constrains
        read -p "How many fields to create: " nf
          x=1
        pkFlag=0
        while [ $x -le $nf ]; do
          read -p "Field $x's Name: " fld
          elseFlag=0                        #other constrains flag to check
          if [[ $pkFlag == 0 ]]; then
            read -p "Is it the Primary Key? (y/n) " pk
            if [[ $pk == "y" ]]; then      #unique, means not NULL and has no default value
              unique="y"
              notNull="y"
              hasDef="n"
              pkFlag=1
              elseFlag=1
            fi
          fi
            if [[ $elseFlag != 1 ]]; then      #unique, means not NULL and has no default value
              pk="n";
              read -p "Is the field Unique? (y/n) " unique
              if [ $unique = "y" ]; then  #not NULL and has no default value
                notNull="y";
                hasDef="n";
              else
                read -p "The filed is NOT NULL? (y/n) " notNull
                read -p "Is the field has Default Value (y/n)? " hasDef
                if [ $hasDef = "y" ]; then
                  read -p "Enter Default value: " hasDef
                fi
              fi
            fi
          # fi
          if [ $hasDef = "n" ];then
            read -p "Enter Data Type (int - char - varchar ): " dataType
            if [ $dataType = "int" ]; then
              dataType="int";
            elif [ $dataType = "char" ]; then
              dataType="char"
            else
              dataType="varchar";
            fi
          fi
          saveCons=" ";
          saveCons="$fld:$pk:$notNull:$unique:$hasDef:$dataType";

          echo "$saveCons" >> ./$DB_NAME/$tableName.cons
          x=`expr $x + 1`;
        done
        echo "Table Created Successfully"
      fi
    else
        echo "No DataBase used!"
    fi
  else
    echo "Syntax Error!"
  fi
}

#######################################
function useDB(){
  if [[ "${arr[0]}" = "use" && -d "${arr[1]}" ]]; then
    let "USEDB_FLAG=1";
    declare -g "DB_NAME=${arr[1]}";
    echo "DataBase changed"
  else
    echo "Please enter a valid DataBase name"
  fi
}

#######################################
function alterTable(){
    if (( USEDB_FLAG != 0 )); then
    if [[ "${arr[0]}" == "alter" && "${arr[1]}" == "table" ]]
    then
        tableName="./$DB_NAME/${arr[2]}.table"
        consName="./$DB_NAME/${arr[2]}.cons"
        if [ -f $consName ]; then
          if [[ "${arr[3]}" == "change" && "${arr[4]}" == "to" ]]     #chage to 
            then
              if [ -f "./$DB_NAME/${arr[5]}.table" ]; then
                echo "Table already exists by that name"
              else
                mv $tableName ./$DB_NAME/${arr[5]}.table
                mv $consName ./$DB_NAME/${arr[5]}.cons
                echo "Table name changed to ${arr[5]}"
                tableName="./$DB_NAME/${arr[5]}.table"
                consName="./$DB_NAME/${arr[5]}.cons"
              fi
          elif [ "${arr[3]}" = "add" ]; then                          #add
            awk -F ":" -v column="${arr[4]}" 'BEGIN { if($1==column) { print "1"; } } ' "$consName"
              fields=""
              echo "Field's Name is: ${arr[4]} " ;
              #read -r fld;
              fld="${arr[4]}";
              read -p "Is it the Primary Key? (y/n) " pk
              # pkFlag=1
              if [[ $pk == "y" ]]; then      #unique, means not NULL and has no default value
                unique="y"
                notNull="y"
                hasDef="n"
              else
                read -p "Is the field Unique? (y/n) " unique
                if [ $unique = "y" ]; then  #not NULL and has no default value
                  notNull="y";
                  hasDef="n";
                else
                  read -p "The filed is NOT NULL? (y/n) " notNull
                  read -p "Is the field has Default Value (y/n)? " hasDef
                  if [ $hasDef = "y" ]; then
                    read -p "Enter Default value: " hasDef
                  fi
                fi
              fi
            # fi
            if [ $hasDef = "n" ];then
              read -p "Enter Data Type (int - char - varchar ): " dataType
              if [ $dataType = "int" ]; then
                dataType="int";
              elif [ $dataType = "char" ]; then
                dataType="char"
              else
                dataType="varchar";
              fi
            fi
            saveCons=" ";
            saveCons="$fld:$pk:$notNull:$unique:$hasDef:$dataType";

            echo "$saveCons" >> ./$DB_NAME/${arr[2]}.cons
            echo "Table ${arr[2]} Altered Successfully"

  elif [ "${arr[3]}" = "drop" ]; then
            var1=`awk -F':' -v str="${arr[4]}" 'BEGIN { if($1==str) { if($2=="y") print "1"; } } END { }' "$consName"`
            if [ "$var1" != "1" ]; then
              echo "Dropping Column ${arr[4]}"
              if [ -f temp ]
              then
              rm temp
              fi
              awk -F':' -v str="${arr[4]}" 'BEGIN { IGNORECASE=1; } { if($1!=str) { print $0; } } END { }' "$consName" >> temp
                cat temp > "$consName"

                var=`head -n 1 $tableName`
                IFS=":" read -a allFields <<< "$var";

                index=1;
                for i in "${allFields[@]}"
                  do
                    if [[ $i == "${arr[4]}" ]]; then
                      break;
                    else
                      index=`expr $index + 1`
                    fi
                done
                if [ -f temp ]; then
                rm temp
                fi
                awk -F':' -v indVar="$index" 'BEGIN { IGNORECASE=1; }
                  {
                        row=""
                        for(i=1;i<=NF;i++)
                        {
                          if(i!=indVar)
                          {
                            if(i!=NF)
                              row=row $i":"
                            else
                              row=row $i
                          }
                        }
                      print row
                  }' "$tableName" > temp
                  cat temp > "$tableName"
            else
              echo "Primary Key can't be dropped"
            fi
          else
            echo "Alter Syntax Error"
          fi
        else
          echo "Table ${arr[2]} doesn't exist"
        fi
    else
      echo "Syntax Error"
  fi
else
    echo "Use database first"
fi
}

#######################################
function dropDBsTb(){
      if [[ "${arr[0]}" == "drop" && "${arr[1]}" == "table" ]]; then
    if (( USEDB_FLAG != 0 )); then
        tableName="./$DB_NAME/${arr[2]}.table"
        consName="./$DB_NAME/${arr[2]}.cons"
      if [ -f $consName ]; then
        rm -f "$tableName"
        rm -f "$consName"
        echo "Table ${arr[2]} deleted successfully"
      else
        echo "Table doesn't exist!"
      fi
    else
      echo "Use database first"
    fi
  elif [[ "${arr[0]}" = "drop" && "${arr[1]}" = "database" ]]; then
    if [ -d "${arr[2]}" ]; then
      rm -dr "${arr[2]}"
      echo "Database ${arr[2]} deleted successfully"
    else
      echo "Table doesn't exist!"
    fi
  else
    echo "Syntax error!"
  fi
}

#######################################
function selectRecord(){
   	if [ "${arr[1]}" == "*" ]; then
    		tableName="$DB_NAME/${arr[3]}.table"
	    	if [[ -f $tableName  ]]; then
	      	awk -F ":" 'BEGIN { IGNORECASE=1; }
	      {
		for(i=1;i<=NF;i++)
		printf ("%15s",$i);
		printf("\n");
	      }
	      END { printf ("\n"); }' "$tableName"
		fi
	else 

		
		table="a/b.table"
		tableCons="a/b.cons"
		for line in `cat $tableCons`	# this for loop to push the colomn names of the table into array (args) 
		do
			item=`echo $line |cut -d\: -f1`
			 args+=("$item")
		done
		for x in "${!arr[@]}"; #this for to loop the query cammands   
		do 
			if [[ ${arr[$x]} = "where" ]] ; then 
					indexOfwhere=$x # get where index
					colname=$(($x + 1)) # get colomn name after where phrase 
					val=$(($x +3))  # get the value of colomn name after where phrase

						#echo "${arr[$colname]}" "${arr[$val]}" 
			fi
		done

		for (( c=1; c<$indexOfwhere; c++ ))  
			do 
					for i in "${!args[@]}"; do
					   if [[ "${args[$i]}" = "${arr[$c]}" ]]; then
						index=$(($i ))
						#echo "${args[$index]}"
						index1=$((index + 1)) 
			val=`awk -F: -v value="${arr[$indexOfwhere + 3]}" -v val="$index1" '{$1=$val; if($1==value){a=system("echo "$0)}}'  $table`
				#awk '{ print $index }' <<< "$val"
					echo $val
					#echo $index1
					#a=$(($index1 + 1))
					#cut -d' ' -f$a  <<< "$val"

					    fi
					done	
			done

	fi
}

#######################################
function uniqueRec(){
  uniFlag=0;
  noOfRec=`awk 'BEGIN{a=0;} { a++; } END{print a;}' $1`;
  for (( i=1;i<=$noOfRec;i++ ))
  do
    firstRec=`awk -F ":" -v rec1=$i -v rec2=$2 ' NR == rec1 { print $rec2 } ' $1`;
    for (( x=$i+1;x<=$noOfRec;x++ ))
    do
      secondRec=`awk -F ":" -v rec1=$x -v rec2=$2 ' NR == rec1 { print $rec2 } ' $1`;
      if [ $firstRec = $secondRec ]; then
        uniFlag=1;
        break;
      fi
      if [ $firstRec = $3 ]; then
        uniFlag=1;
        break;
      fi
      if [ $secondRec = $3 ]; then
        uniFlag=1;
        break;
      fi
    done
  done
  echo $uniFlag;
}
###########insertRecord###########
function insertRecord(){
  if (( USEDB_FLAG != 0 )); then
    if [[ ${arr[0]} = "insert" && ${arr[1]} = "into" ]]; then
    tableName="./$DB_NAME/${arr[2]}.table"
    consName="./$DB_NAME/${arr[2]}.cons"
    if [ -f $consName ]; then
      consFlag="y";
      noRows=`awk 'BEGIN{i=0;} { i++; } END{print i;}' $consName`;
      noColumns=`awk -F ":" ' NR == 1 {print NF}' $consName`;
      x=1
      while [ $x -le $noRows ]
      do
        i=0;
        while [ $i -lt $noColumns ]
        do
          noOfLi=i;
          i=`expr $i + 1`;
          consR[noOfLi]=`awk -F ":" -v rec1=$x -v rec2=$i ' NR == rec1  { print $rec2  }' $consName`;
        done

        #$fld:$pk:$notNull:$unique:$hasDef:$dataType

        echo "Field : ${consR[1]}"
        read -r value[$x];
        if [ ${consR[2]} = "y" ]; then   #Primary, NotNULL, unique, no default value
          # xyz=`awk -F ";" 'NR == $x {p=$1; next} p == rec[$x] { "0" } { "1" }' $tableName`
          if [ $( uniqueRec $tableName $x ${value[$x]} ) -eq 1 ]; then
            echo "Primary Key must be unique"
            consFlag="n"
            break;
          fi
        fi
        if [[ ${consR[3]} = "y" && $consFlag != "n" ]]; then    #NotNull
          if [ ${value[$x]} = "" ]; then
            consFlag="n";
          fi
        fi
        if [[ ${consR[4]} = "y" && $consFlag != "n" ]]; then   #unique
          ret=$( uniqueRec $tableName $x ${value[$x]} );
          if [ $ret -eq 1 ]; then
            echo "Unique field duplicated"
            consFlag="n";
            break;
          fi
        fi
        if [[ ${consR[5]} != "n"  && $consFlag != "n" ]]; then  #Default value
          if [[ ${value[$x]} == "" ]]; then
            echo "${consR[5]}"
            value[$x]=${consR[5]}
            echo "Default value inserted"
          fi
        fi

        if [[ ${consR[5]} == "n" ]]; then
          dataType=`echo "${consR[6]}" | awk -F ":" ' { print $1 } '`    #dataType
          if [ $dataType == "int" ]; then
            if [[ "${value[$x]}" != '' && "${value[$x]}" == *[0-9]* ]]; then
              echo "Valid"
            else
              echo "Invalid, not Integer"
              consFlag="n"
              break;
            fi
          elif [ $dataType == "char" ]; then
            if [[ "${value[$x]}" == *[a-zA-Z]* ]]; then
              echo "Valid"
            else
              echo "Invalid, not alphabatical Characters"
              consFlag="n"
              break;
            fi
          else
            echo "Valid";
          fi
        fi
        x=`expr $x + 1`;
      done
      record="";
      for (( a=1;a<=$noRows;a++ ))
      do
        if (( $a<$noRows ))
        then
          record="$record${value[$a]}:";
        else
          record="$record${value[$a]}";
        fi
      done
      if [ $consFlag != "n" ]; then
        echo "$record" | cat >> $tableName
        echo "Values inserted successfully"
      else
        echo "Something is Wrong, check the constrains!"
      fi
    else
      echo "Table doesn't exist!"
    fi
  fi
else
  echo "Use database first"
fi
}

#######################################
function updateRecord(){
  if (( USEDB_FLAG != 0 )); then
	   # update   user       set         name       =     khaled    where      id          =    1
    #echo "${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} ${arr[6]} ${arr[7]} ${arr[8]}${arr[9]}  "
	 
	tableCons="$DB_NAME/${arr[1]}.cons"
	tableName="$DB_NAME/${arr[1]}.table"
	args=()

	for line in `cat $tableCons`	# this for loop to push the colomn names of the table into array (args) 
	do
		item=`echo $line |cut -d\: -f1`
		 args+=("$item")
	done
	#echo "${args[@]}" 
	#get colonms names of the table
	#echo "${arr[@]}"

	for x in "${!arr[@]}"; #this for to loop the query cammands   
	do 
		if [[ ${arr[$x]} = "where"  ]] ; then 
			indexOfwhere=$x # get where index
			colname=$(($x + 1)) # get colomn name after where phrase 
			val=$(($x +3))  # get the value of colomn name after where phrase

				#echo "${arr[$colname]}" "${arr[$val]}"

			for i in "${!args[@]}"; 
			do
				if [[ "${args[$i]}" = "${arr[$colname]}" ]]; then
						indexofcol=$(($i + 1)) # get the order of colomn (after where) of the table
				fi
			done
	
								#loop for 
			for (( c=3; c<$indexOfwhere; c++ ))  
			do  
					for i in "${!args[@]}"; do
					   if [[ "${args[$i]}" = "${arr[$c]}" ]]; then
						index=$(($i))
						#echo "${args[$index]}"
				

					for i in "${!args[@]}"; 
						do
							if [[ "${args[$i]}" = "${args[$index]}" ]]; then
									indexofupdatecol=$(($i + 1))
							fi
						done

				
					val=`awk -F: -v value="${arr[$indexOfwhere + 3]}" -v val="$indexofcol" '{$1=$val; if($1==value){a=system("echo "$0) } }' $tableName`
					oldvalue=`echo $val | cut -d\  -f$indexofupdatecol`

					sed "s/$oldvalue/${arr[$c + 2]}/" $tableName > tmp && mv tmp $tableName
			
					   fi
					done
					 		
			done
 	  
		fi
			
	done
	else 
  echo "Use database first"
fi											
}
#######################################
function deleteRecord(){
  if (( USEDB_FLAG != 0 )); then
	  # delete    from       user        where   id          =             1 
      #echo "${arr[0]} ${arr[1]} ${arr[2]} ${arr[3]} ${arr[4]} ${arr[5]} ${arr[6]}  ${arr[7]} ${arr[8]} ${arr[9]}"
	tableCons="$DB_NAME/${arr[2]}.cons"
	tableName="$DB_NAME/${arr[2]}.table"
	args=()
	
	if  [[ "${arr[1]}" != "from"  ]]; then 
			echo "syntax error"				
	fi

	if  [[ "${arr[3]}" != "where"  ]]; then 
			echo "syntax error"
	fi

	for line in `cat $tableCons`	
	do
		item=`echo $line |cut -d\: -f1`
		 args+=("$item")
	done
		
	#echo ${args[@]}
	for i in "${!args[@]}"; 
	do
		if [[ "${args[$i]}" = "${arr[4]}" ]]; then
				index=$(($i + 1))
		fi
	done
	#echo $index
	delrows=()
	 if [[ "${arr[5]}" = '=' ]] ;then
	   	a=`awk -F: -v value="${arr[6]}" -v val="$index" -v table="$tableName" '{$1=$val ;if($1==value)
		{a=system("echo "$0)   }   }' $tableName`
		b=`echo $a | cut -d\  -f1`
		sed -i "/$b/d" $tableName

		#awk -F: -v var="khaled" '{print $1 var}'  $tableName
		
	elif [[ "${arr[5]}" = '>' ]] ;then
		
		a=`awk -F: -v value="${arr[6]}" -v val="$index" -v table="$tableName" '{$1=$val ;if($1>value)
		{a=system("echo "$0)   }   }' $tableName`
		
		for del in $a
		do
			b=`echo $del | cut -d\  -f1`
			sed -i "/$b/d" $tableName
		done
		
		

	elif [[ "${arr[5]}" = '<' ]] ;then
		a=`awk -F: -v value="${arr[6]}" -v val="$index" -v table="$tableName" '{$1=$val ;if($1<value)
		{a=system("echo "$0)   }   }' $tableName`

		for del in $a
		do
			b=`echo $del | cut -d\  -f1`
			sed -i "/$b/d" $tableName
		done
		
		
	
	elif [[ "${arr[5]}" = '>=' ]] ;then
		a=`awk -F: -v value="${arr[6]}" -v val="$index" -v table="$tableName" '{$1=$val ;if($1<=value)
		{a=system("echo "$0)   }   }' $tableName`
		b=`echo $a | cut -d\  -f1`
		sed -i "/$b/d" $tableName
		

	elif [[ "${arr[5]}" = '<=' ]] ;then
		a=`awk -F: -v value="${arr[6]}" -v val="$index" -v table="$tableName" '{$1=$val ;if($1<=value)
		{a=system("echo "$0)   }   }' $tableName`
		b=`echo $a | cut -d\  -f1`
		sed -i "/$b/d" $tableName

	elif [[ "${arr[5]}" = '!=' ]] ;then
		a=`awk -F: -v value="${arr[6]}" -v val="$index" -v table="$tableName" '{$1=$val ;if($1!=value)
		{a=system("echo "$0)   }   }' $tableName`
		b=`echo $a | cut -d\  -f1`
		sed -i "/$/d" $tableName
	fi
	   

	#awk -F':' '{if ($2=='${arr[6]}') records=sed /$0/d $tableName }' $tableName
	#echo $records > $tableName
	#echo "succesfully deleted" 
	#cat $tableName | while read line
	#do
	    #echo $line
	#done
	else 
  echo "Use database first"
fi		
}

#######################################
function sortTable(){
  if (( USEDB_FLAG != 0 )); then
	args=()
	argscons=()
	
	tableName="./$DB_NAME/${arr[1]}.table"
	tableCons="./$DB_NAME/${arr[1]}.cons"
	


	for line in `cat $tableCons`	
	do
		item=`echo $line |cut -d\: -f1`
		cons=`echo $line |cut -d\: -f6`
		 args+=("$item")
		argscons+=("$cons")
	done
		
	for i in "${!args[@]}"; 
	do
		if [[ "${args[$i]}" = "${arr[3]}" ]]; then
				index=$(($i + 1))
		fi
	done
		
	if [[ ${argscons[$index - 1 ]} = "int" ]]; then 

		if [[ ${arr[4]} = "DESC" ]]; then
			sort  -t: -n -r -k $index  $tableName
		elif [[ ${args[4]} = "ASC" ]]; then
			sort  -t: -n -k $index  $tableName
		else
			sort  -t: -n -k $index  $tableName
		fi

	else 	
		
		if [[ ${arr[4]} = "ASC" ]]; then
			sort  -t: -k $index  $tableName
		elif [[ ${arr[4]} = "DESC" ]]; then
			sort -t: -r -k $index  $tableName
		else
			sort  -t: -k $index  $tableName
		fi
	fi
	else 
  echo "Use database first"
fi		
}

#######################################
function displayTable(){
  if (( USEDB_FLAG != 0 )); then
    	tableCons="$DB_NAME/${arr[1]}.cons"
	tableName="$DB_NAME/${arr[1]}.table"
	for line in `cat $tableCons`	
	do	
		for l in $line 
		do
			con1=`echo $l | cut -d: -f1`
			con2=`echo $l | cut -d: -f2`
			con3=`echo $l | cut -d: -f3`
			con4=`echo $l | cut -d: -f4`
			con5=`echo $l | cut -d: -f5`
			con6=`echo $l | cut -d: -f6`
		
		if [[ $con2 = "y" ]]; then
			echo "$con1 is a primary key"
		else
			echo "$con1 is not a primary key"
		fi

		if [[ $con3 = "y" ]]; then
			echo "$con1 accept NULL"
		else
			echo "$con1 not accept  NULL"
		fi


		if [[ $con4 = "y" ]]; then
			echo "$con1 is UNIQUE"
		else
			echo "$con1 is not UNIQUE"
		fi


		if [[ $con5 != "n" ]]; then
			echo "$con1 has Default value $con5"
		else 
			echo "$con1 has not Default value "
		fi
		
		echo " the datatype of $con1 is $con6 "
			
		done
		echo "==============================="	 
	done
	else 
  echo "Use database first"
fi		
}

#######################################
function helpFun(){
    if [[ ${arr[0]} == "--help" ]]; then
      less help_docs.help
    else
      echo "Syntax error"
    fi

}

#######################################
function initialize(){
  read -p "query >>> " query
  IFS=' ' read -a arr <<< "$query";    #IFS "internal field separator"
  case "${arr[0]}" in
    show)
      showDBs $arr
    ;;

    create)         #create DB or table
      createDBsTb $arr
    ;;

    use)
      useDB $arr
    ;;

    alter)
      alterTable $arr
    ;;

    drop)           #drop DB or table
      dropDBsTb $arr
    ;;

    select)
      selectRecord $arr
    ;;

    insert)
      insertRecord $arr
    ;;

    update)
      updateRecord $arr
    ;;

    delete)
      deleteRecord $arr
    ;;

    sort)
      sortTable $arr
    ;;

    desc)
      displayTable $arr
    ;;

    exit)
      echo "exiting ..."
      sleep 1
      exit
    ;;

    --help)
      helpFun $arr
    ;;

    *)
      echo "Wrong Syntax, check your initial word or write --help:"
    ;;
  esac
}
#####################################################

echo "Welcome To Our DBMS"
echo "Simple explanation on how to use our DBMS:  "
echo "You can write queries like using mysql DBMS ex:  "
echo "create database 'the name of the new database without the quotes'  "
echo "For more help & elaborated explanation on how to use it, please write --help file "

while true; do
  initialize
done
