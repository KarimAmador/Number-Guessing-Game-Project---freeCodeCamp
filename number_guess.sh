#!/bin/bash
PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

echo Enter your username:
read USERNAME

PLAYER_INFO=$($PSQL "SELECT * FROM player_info WHERE username='$USERNAME'")

if [[ -z $PLAYER_INFO ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_PLAYER_RESULTS=$($PSQL "INSERT INTO player_info(username) VALUES('$USERNAME')")
else
  IFS='|' read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $PLAYER_INFO

  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE player_info SET games_played = games_played + 1 WHERE username = '$USERNAME'")

NUMBER=$(( RANDOM % 1000 + 1 ))
echo Guess the secret number between 1 and 1000:

NUMBER_OF_GUESSES=0
while [[ $GUESS -ne $NUMBER ]]
do
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  read GUESS

  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read GUESS
  done

  if [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
done

echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!
UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE player_info SET best_game = CASE WHEN $NUMBER_OF_GUESSES > best_game THEN $NUMBER_OF_GUESSES ELSE best_game END WHERE username = '$USERNAME'")
