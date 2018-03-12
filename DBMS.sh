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
              mv $tableName ./$DB_NAME/${arr[5]}.table
              mv $consName ./$DB_NAME/${arr[5]}.cons
              echo "Table name changed to ${arr[5]}"
              tableName="./$DB_NAME/${arr[5]}.table"
              consName="./$DB_NAME/${arr[5]}.cons"
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
   echo "select"
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
    echo "update"
}

#######################################
function deleteRecord(){
    echo "delete"
}

#######################################
function sortTable(){
    echo "sort"
}

#######################################
function displayTable(){
    echo "display"
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

    *)
      echo "Wrong Syntax, check your initial word it should be one of these:"
      echo "show, create, use, alter, drop, select, insert, update, delete, sort, display, exit"
    ;;
  esac
}
#####################################################

echo "Welcome To Our DBMS"
echo "Simple explanation on how to use our DBMS:  "
echo "You can write queries like using mysql DBMS ex:  "
echo "create database 'the name of the new database without the quotes'  "
echo "For more help & elaborated explanation on how to use it, please go to README file "

while true; do
  initialize
done
