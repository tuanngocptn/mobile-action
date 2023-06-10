send_telegram() {
  if [ "${2}" ]; then
    if [ "${3}" ]; then
      send_telegram_topic $1 $2 "$3"
    else
      send_telegram_normal $1 "$2"
    fi
  else
    send_telegram_liberty $1
  fi
}

send_telegram_normal() {
  curl --location "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    --header 'Content-Type: application/json' \
    --data '{
      "chat_id": "'"$1"'",
      "text": "'"$2"'"
  }'
}

send_telegram_topic() {
  curl --location "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    --header 'Content-Type: application/json' \
    --data '{
      "chat_id": "'"$1"'",
      "reply_to_message_id": "'"$2"'",
      "text": "'"$3"'"
  }'
}

send_telegram_liberty() {
  curl --location "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
    --header 'Content-Type: application/json' \
    --data '{
      "chat_id": -1001837632261,
      "reply_to_message_id": 196,
      "text": "'"$1"'"
  }'
}

send_slack() {
  curl --location "https://hooks.slack.com/services/$SLACK_BOT_SERVICE_ID" \
    --header 'Content-Type: application/json' \
    --data '{"text":"'"$1"'"}'
}
