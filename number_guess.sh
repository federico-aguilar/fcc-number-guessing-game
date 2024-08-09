#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME
#Attempt to grab name
USER_ID=$($PSQL "SELECT user_id FROM Users WHERE name='$USERNAME'")
#USER_ID=""
if [[ -z $USER_ID ]]
then
  #Add username to USERS
  NEW_USER=$($PSQL "INSERT INTO Users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM Users WHERE name='$USERNAME'")
  #Salute
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM Games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM Games WHERE user_id=$USER_ID")
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

#Run rest of app
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
ATTEMPTS=0
echo "Guess the secret number between 1 and 1000:"
read GUESS
until [[ $GUESS == $SECRET_NUMBER ]] 
do
  if [[ $GUESS =~ ^-?[0-9]+$ ]]
  then
    (( ATTEMPTS++ ))
    if [ $GUESS -lt $SECRET_NUMBER ]; then
      echo "It's higher than that, guess again:"
      read GUESS
    else
      echo "It's lower than that, guess again:"
      read GUESS
    fi
  else
    (( ATTEMPTS++ ))
    echo "That is not an integer, guess again:"
    read GUESS
  fi
done
(( ATTEMPTS++ ))

SAVE=$($PSQL "INSERT INTO Games(user_id, guesses) VALUES($USER_ID, $ATTEMPTS)")
echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"
