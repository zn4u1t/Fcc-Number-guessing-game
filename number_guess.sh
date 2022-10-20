#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"

if [[ $1 ]]
then
  echo -e "\n$1"
fi

read USER_INPUT
USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USER_INPUT'")
HIGH_SCORE=$($PSQL "SELECT high_score FROM users WHERE username='$USER_INPUT'")
GAME_NUM=$($PSQL "SELECT games_played FROM users WHERE username='$USER_INPUT'")
# check for existing username
if [[ -z $USERNAME ]]
then
  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USER_INPUT')")
  echo "Welcome, $USER_INPUT! It looks like this is your first time here."
  GAMES_PLAYED=0
else
  echo "Welcome back, $USER_INPUT! You have played $GAME_NUM games, and your best game took $HIGH_SCORE guesses."
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USER_INPUT'")
fi


echo "Guess the secret number between 1 and 1000:"
(( GAMES_PLAYED+=1 ))
GAME_COUNT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED")
read NUM_GUESS

# if input not a number, make user enter new input
GUESS_AGAIN () {
  echo "That is not an integer, guess again:"
  read NUM_GUESS
  NUM_PICK
}

NUM_PICK () {
  if [[ ! $NUM_GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_AGAIN
  fi
}

NUM_PICK

GUESS_AGAIN_WRONG_NUM () {
  read NUM_GUESS
  GUESS_CHECK
}

# random number generator
RANDOM_NUM=$(echo $(( $RANDOM % 1000 + 1 )))
# score counter for how many tries
SCORE=0

GUESS_CHECK () {
  if [[ $RANDOM_NUM = $NUM_GUESS ]]
  then
    (( SCORE+=1 ))
    echo "You guessed it in $SCORE tries. The secret number was $RANDOM_NUM. Nice job!"
    # checks for a high score to compare to. if none found, current value inserted
    GAME_SCORE=$($PSQL "UPDATE users SET high_score=$SCORE WHERE username='$USER_INPUT' AND (high_score IS NULL OR high_score > $SCORE)")
  else
    if [[ $RANDOM_NUM -gt $NUM_GUESS ]]
    then
      echo "It's higher than that, guess again:"
      #echo "random num is $RANDOM_NUM"
      (( SCORE+=1 ))
      GUESS_AGAIN_WRONG_NUM
    elif [[ $RANDOM_NUM -lt $NUM_GUESS ]]
    then
      echo "It's lower than that, guess again:"
      #echo "random num is $RANDOM_NUM"
      (( SCORE+=1 ))
      GUESS_AGAIN_WRONG_NUM
    fi
  fi
}

GUESS_CHECK