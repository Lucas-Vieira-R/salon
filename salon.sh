#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c";

echo -e "\nWELCOME TO MY SALON! :)";
echo -e "\nWhat do you want for today?";

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT * FROM services");
  if [[ -z $SERVICES ]]
  then
    echo -e "\nSorry, we dont open today :(";
  else
    echo -e "\nHere are our services:";
    echo "$SERVICES" | while read service_id bar serviceName
    do
    echo "$service_id) $serviceName"
    done
    read SERVICE_ID_SELECTED;
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
      then
        # send to main menu
        echo "That is not a valid service number. Try again";
        MAIN_MENU;
      else
        serviceAvailable=$($PSQL "SELECT service_id from services where service_id=$SERVICE_ID_SELECTED");
        if [[ -z $serviceAvailable ]]
        then
          echo "That is not a valid service number. Try again";
          MAIN_MENU;
        else
        #Get customers
          echo -e "\nOkay, now, whats yout phone number?";
          read CUSTOMER_PHONE;
          iscustomer=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'");
          if [[ -z $iscustomer ]]
          then
            echo -e "\nSo whats your name?";
            read CUSTOMER_NAME;
            insertresult=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')");
          fi
          customerId=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'");
          customerName=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'");
          serviceName=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED");
          echo -e "\nWhat time are you available?";
          read SERVICE_TIME;
          insertAppointment=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($customerId,$SERVICE_ID_SELECTED,'$SERVICE_TIME')");
          echo -e "\nI have put you down for a $serviceName at $SERVICE_TIME, $(echo $customerName | sed -r 's/^ *| *$//g').";
          exit
        fi
    fi
  fi
}
MAIN_MENU;
exit;
