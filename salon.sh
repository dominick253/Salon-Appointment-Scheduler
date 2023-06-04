#!/bin/bash


# Fetch the list of services
SERVICES=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT service_id || ') ' || name FROM services ORDER BY service_id;")

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
echo "$SERVICES"
read SERVICE_ID_SELECTED


# Make sure the service ID exists
SERVICE_EXISTS=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT EXISTS(SELECT 1 FROM services WHERE service_id = $SERVICE_ID_SELECTED);")


while [ "$SERVICE_EXISTS" = "f" ]
do
    echo -e "\nI could not find that service. What would you like today?"
    echo "$SERVICES"
    read SERVICE_ID_SELECTED
    SERVICE_EXISTS=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT EXISTS(SELECT 1 FROM services WHERE service_id = $SERVICE_ID_SELECTED);")
done

SERVICE_SELECTED=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
echo "What's your phone number?"
read CUSTOMER_PHONE


# Check if the phone number exists in the database
PHONE_EXISTS=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT EXISTS(SELECT 1 FROM customers WHERE phone = '$CUSTOMER_PHONE');")


# If the phone number doesn't exist, ask for the customer's name and add it to the database
if [ "$PHONE_EXISTS" = "f" ]
then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
fi

CUSTOMER_NAME_FROM_DATABASE=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
# Get the customer_id for the phone number
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")


echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME_FROM_DATABASE?"
read SERVICE_TIME


# Add the appointment to the appointments table
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"


# Get the name of the service
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -tAc "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")


# Confirm the appointment
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME_FROM_DATABASE."

