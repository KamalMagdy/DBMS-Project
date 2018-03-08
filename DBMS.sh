#!/bin/bash

USEDB_FLAG=0
DB_NAME=""
# pkFlag=0

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
        while [ $x -le $nf ]; do
          read -p "Field $x's Name: " fld
          # if [[ $pkFlag == 0 ]]; then
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
    echo "alter"
}

#######################################
function dropTable(){
    echo "drop"
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
            ${value[$x]}=${consR[5]}
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
