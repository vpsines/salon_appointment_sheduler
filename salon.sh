#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
    then
    echo -e "$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  
  # display services
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done 
  # read selected service
  read SERVICE_ID_SELECTED

  # check if selected service exists
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE SERVICE_ID=$SERVICE_ID_SELECTED;")
  # if not found
  if [[ -z $SELECTED_SERVICE ]]
    then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    # get phone no
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # check if customer exists
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    # if customer not found
    if [[ -z $CUSTOMER_NAME ]]
      then
      # ask user to name
      echo -e "\nI don't have a record for that phone number, what's your name?";
      read CUSTOMER_NAME
      # insert customer
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
    fi

    # read appoinment time
    echo -e "\nWhat time would you like your $SELECTED_SERVICE, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

    # insert appoinment
    BOOK_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME');")
    
    # show  appoinment status
    if [[ -z $BOOK_APPOINTMENT_RESULT ]]
      then
      echo -e "\nSorry for the inconvenience. We are facing some issue\n"
    else
       echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  fi
}

MAIN_MENU
