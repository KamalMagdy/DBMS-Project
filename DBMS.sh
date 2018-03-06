function showDBs(){
    #code here ...
}

#######################################
function createDBsTb(){
    #code here ...
}

#######################################
function useDB(){
    #code here ...
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

    exit)
      echo "exiting ..."
      sleep 1
      exit
    ;;

    *)
      echo "Wrong Syntax, check your initial word it should be one of these:"
      echo "show, create, use, alter, drop, select, insert, update, delete, exit"
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