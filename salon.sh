#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU()
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else 
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  SERVICES=$($PSQL "select service_id, name from services;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  
  SERVICE_RESULT=$($PSQL "Select name from services where service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_RESULT ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else 

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    fi
    
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    echo $CUSTOMER_ID
    
    echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME |  sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME

    APPOINTMENT_BOOKING_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    echo -e "\nI have put you down for a $(echo $SERVICE_RESULT |  sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME |  sed -r 's/^ *| *$//g').\n"
  fi
}

MAIN_MENU 