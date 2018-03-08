#!/bin/bash
USEDB_FLAG=0
DB_NAME=""
DB_used=""


<<COMMENT1



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
      echo "Database ${arr[2]} created suceessfully"
    fi
  else
    echo "Syntax Error!"
  fi
}

#######################################
function useDB(){
  if [[ "${arr[0]}" = "use" && -d "${arr[1]}" ]]; then
    let "USEDB_FLAG=1";
    let "DB_NAME=${arr[1]}";
    echo "DataBase changed"
  else
    echo "Please enter a valid DataBase name"
  fi
}

#######################################
function alterTable(){
    #code here ...
}

#######################################
function dropTable(){
    #code here ...
}

#######################################
function selectRecord(){
    #code here ...
}

#######################################
function insertRecord(){
    #code here ...
}

#######################################
function updateRecord(){
    #code here ...
}

#######################################
function deleteRecord(){
    #code here ...
}

#######################################
function sortTable(){
    #code here ...
}

#######################################
function displayTable(){
    #code here ...
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
COMMENT1

#######################################
function selectDB() {
  echo -e "Enter Database Name: "
  read dbName
  cd $HOME/Desktop/$dbName 2>>errorshappend.log
  if [[ $? == 0 ]]; then
    echo "Database $dbName was Successfully Selected"
     DB_used=$dbName 
    $1
  else
    echo "Database $dbName wasn't found"
  $1
  fi
}

function checkSelectedDB()
{

	if [ -z $DB_used ];
	then 
	echo "No Data base Selected Please Select Database"
	$1

	fi 

}

########################################

function selectMenOptions()
{

  echo -e "\n---------select options Menu-------------"
  echo "| 1. use or change Database     "
  echo "| 2. select All            		"
  echo "| 3. Select Specific Column     "
  echo "| 4. Select All From Table with condition(where)"
  echo "| 5. Select specific Column From Table with condition(where)"
 echo "| 6. back to Main menu"
 echo "| 7. exit             "

echo  "Enter Choice:";
read  choice;

case $choice in
	1) selectDB selectMenOptions ;;
	2) selectAll ;;
	3) selectColumn;;
	4) selectByCond;;
	5) selectColByCond;;
	6) FirstMenu ;;
	7) exit ;;
	*) echo "wrong choice"  FirstMenu
	
esac


selectMenOptions;
}

#######################################################################
function SortMenunOptions()
{

  echo -e "\n--------- Sort options Menu-------------"
  echo "| 1. use or change Database     "
  echo "| 2. Sort By  filed  Asec"
  echo "| 3. Sort By  filed  Dsec"
 echo "| 4. back to Main menu"
 echo "| 5. exit             "



echo  "Enter Choice:";
read  choice;

case $choice in
	1) selectDB SortMenunOptions ;;
	2) sortTableAsc;;
	3) echo "hi";;
	4) FirstMenu ;;
	5) exit ;;
	*) echo "wrong choice"  FirstMenu
	
esac


SortMenunOptions;

}

#######################################################################

function FirstMenu()
{

  echo -e "\n---------Main Menu-------------"
  echo "| 1. write a query              |"
  echo "| 2. Select From  Table         |"
  echo "| 3. sort Table                 |"
  echo "| 4. drop Table                 |"
  echo "| 5. exit                		|"

echo  "Enter Choice:";
read  choice;

case $choice in
	1) echo "hii";;
	2) selectMenOptions;;
	3) SortMenunOptions;;
	4) echo "drop table";;
	5) exit ;;
	*) echo "wrong choice" FirstMenu
	
esac




}
#################################################################################
function selectAll()
{

checkSelectedDB selectMenOptions ; #check if user select data base or not 
  echo -e "Enter Table Name: \c"
  read tName
    if [[ -f ./$tName  ]] ; then 

     column -t -s ':' $tName | tee selectAll.csv  

    else
    	echo "this table does not exits"
    fi
selectMenOptions
}




###############################################################################
function selectColumn()
{
checkSelectedDB selectMenOptions ; #check if user select data base or not 
echo -e "Enter Table Name: \c"
read tName
   if [[ -f ./$tName  ]] ; then 
   echo -e "Enter column Name that you want to select: \c"
   read column
 columnnum=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$column'") print i}}}' $tName)
 		if [[ $columnnum == "" ]]
 		then
 			echo "this column not found"
 			selectMenOptions
 		else
 			echo columnnum 
 			  awk 'BEGIN{FS=":"}{if(NR ==1){print "-------------";print $'$columnnum';print "-------------"};if(NR >1){print $'$columnnum'}}' $tName
 			 awk 'BEGIN{FS=":"}{print $'$columnnum'}' $tName >> selectColumn.csv


 		fi	  
       

    else
    	echo "this table does not exits"
    fi
}
####################################################################################
function selectByCond()
{
checkSelectedDB selectMenOptions ; #check if user select data base or not 
echo -e "Enter Table Name: \c"
read tName
   if [[ -f ./$tName  ]] ; then 

   			echo -e "Enter column Name that you want to  filter by it: \c"
   		read column
 		columnnum=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$column'") print i}}}' $tName)
 			if [[ $columnnum == "" ]]
 			then
 				echo "this column not found"
 			selectMenOptions
 			else
 		 		echo -e "\n choose operator from [== ,<, >, <=, >= ,!=] \c"
 		 		read opt
 		 		if [[ $opt == "==" ]]  || [[ $opt == "<" ]] || [[ $opt == ">" ]] || [[ $opt == ">=" ]] || [[ $opt == "<=" ]]||[[ $opt == "!=" ]]
 		 		then
 		 			 echo -e "\nEnter value of column that you want to filter by it: \c"
      				read val
      				results=$(awk 'BEGIN{FS=":"}{if ($'$columnnum$opt$val') print $0}' $tName 2>>./.error.log |  column -t -s ':')
      				if [[ $results == "" ]] ;then 
      					echo "No  value  like this"
      					selectMenOptions
      				else
      					awk 'BEGIN{FS=":"}{if(NR == 1){print $0}if(NR > 1){if ($'$columnnum$opt$val') print $0}}' $tName 2>>./error.log |  column -t -s ':' >>selectByCond.csv
      					awk 'BEGIN{FS=":"}{if(NR == 1){print "----------------";print $0;print "----------------"}if(NR > 1){if ($'$columnnum$opt$val') print $0}}' $tName 2>>./error.log |  column -t -s ':' 

      				fi	
      						
 		 		else
 		 			echo "wrong operator"
 		 			fi
 		 		fi			



  	else
   	echo "this table does not exits"
  fi




}
#################################################################################
function selectColByCond()
{


checkSelectedDB selectMenOptions ; #check if user select data base or not 
echo -e "Enter Table Name: \c"
read tName
   if [[ -f ./$tName  ]] ; then 
   		echo -e "Enter column Name that you want to select: \c" 
   		read columnselect
   		columnselect=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$columnselect'") print i}}}' $tName)

   		echo -e "Enter column Name that you want to  filter by it: \c"
   		read column
 		columnnum=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$column'") print i}}}' $tName)
 			if [[ $columnnum == "" ]] || [[ $columnselect == "" ]]
 			then
 				echo "column not found"
 			selectMenOptions
 			else
 		 		echo -e "\n choose operator from [== ,<, >, <=, >= ,!=] \c"
 		 		read opt
 		 		if [[ $opt == "==" ]]  || [[ $opt == "<" ]] || [[ $opt == ">" ]] || [[ $opt == ">=" ]] || [[ $opt == "<=" ]]||[[ $opt == "!=" ]]
 		 		then
 		 			echo -e "\nEnter value of column that you want to filter by it: \c"
      				read val
      				results=$(awk 'BEGIN{FS=":"}{if ($'$columnnum$opt$val') print $'$columnselect'}' $tName 2>>./.error.log |  column -t -s ':')
      				if [[ $results == "" ]] ;then 
      					echo "No  value  like this"
      					selectMenOptions
      				else
      					awk 'BEGIN{FS=":"}{if(NR == 1){print $'$columnselect'}if(NR > 1){if ($'$columnnum$opt$val') print $'$columnselect'}}' $tName 2>>./error.log |  column -t -s ':' >>selectColByCond.csv
      					awk 'BEGIN{FS=":"}{if(NR == 1){print "----------------";print $'$columnselect';print "----------------"}if(NR > 1){if ($'$columnnum$opt$val') print $'$columnselect'}}' $tName 2>>./error.log |  column -t -s ':' 

      				fi	
      						
 		 		else
 		 			echo "wrong operator"
 		 			fi
 		 		fi			



  	else
   	echo "this table does not exits"
  fi



}
##################################################################################

function sortTableAsc()
{

checkSelectedDB SortMenunOptions ; #check if user select data base or not 

  echo -e "Enter Table Name: \c"
  read tName
    if [[ -f ./$tName  ]] ; then 

       echo -e "Enter Column name that you want to sort by it: \c"
  		read columnsort
  		columnsort=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$columnsort'") print i}}}' $tName)
  		if [[ $columnsort == "" ]]
 		then
 			echo "this column not found"
 			SortMenunOptions
 			
 		else
 			
 			(head -n 1 $tName |column -t -s ':' && tail -n +2 $tName | sort -t ':' -k$columnsort | column -t -s ':' )
 			 echo "| 1. Save this changes to the source Table"
 			 echo "| 2. Exit"

			echo  "Enter Choice:";
			read  choice;
			case $choice in
			1) (head -n1  $tName && tail -n +2  $tName | sort -t ':' -k$columnsort -o Tempory)
			firstline=$(awk 'BEGIN{FS=":"}{if(NR==1){print $0}}' $tName)
			echo $firstline > $tName
			cat Tempory >> $tName
			clear
			rm -f Tempory
			echo "Your table has been changed Successfully"
				;;

			2) exit ;;
			esac

 		fi	



    else
    	echo "this table does not exits"
    fi



}









#################################################################################
FirstMenu



###############################################################################