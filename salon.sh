#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

MAIN_MENU (){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $HAVE_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INFO_INCLUSION=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')
      echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      read SERVICE_TIME
      APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    else 
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')
      echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
      read SERVICE_TIME
      APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi
}
MAIN_MENU
