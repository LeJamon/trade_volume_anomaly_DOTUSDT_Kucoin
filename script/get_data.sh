#!/bin/bash
#https://api.kucoin.com/api/v1/market/histories?symbol=PDEX-USDT



# call the api
curl -o tempo.json  -X 'GET' 'https://api.kucoin.com/api/v1/market/histories?symbol=DOT-USDT' 

#fetch the data
jq .data tempo.json > data.json

jq -c '.[]' data.json | while read -r line; do
  
  price=$(echo "$line" | jq -r '.price')
  size=$(echo "$line" | jq -r '.size')
  side=$(echo "$line" | jq -r '.side')
  time=$(echo "$line" | jq -r '.time')

  # Insert the values into the table
  sqlite3 ./../database/trade.db "INSERT OR IGNORE INTO Trades (price, size, side, time) VALUES ( '$price', '$size', '$side', '$time');"
done 

#aggregate the trade, trade with the same time are market orders
sqlite3 ./../database/trade.db "INSERT INTO data (time, sum_size, side) SELECT time, SUM(size), side FROM Trades GROUP BY time;"

#find the anomalies using quartile
#here only the Upper Quartile is interestiing because it's tracking big volumes
avg=$(sqlite3 ./../database/trade.db "SELECT AVG(sum_size) FROM data")
size=$(sqlite3 ./../database/trade.db "SELECT COUNT(*) FROM data")
max=$(sqlite3 ./../database/trade.db "SELECT MAX(sum_size) FROM data")
min=$(sqlite3 ./../database/trade.db "SELECT MIN(sum_size) FROM data")

lowerQuartile=$(echo "($min + $avg) / 2" | bc)
upperQuartile=$(echo "($max + $avg) / 2" | bc)

echo $lowerQuartile
echo $upperQuartile
echo $avg

length=$(sqlite3 ./../database/trade.db "SELECT COUNT(*) FROM Anomalie")
echo $length
sqlite3 ./../database/trade.db "INSERT OR IGNORE INTO Anomalie SELECT sum_size, side, time FROM data WHERE sum_size> $upperQuartile ORDER BY sum_size LIMIT 5"
length2=$(sqlite3 ./../database/trade.db "SELECT COUNT(*) FROM Anomalie")

if [[ $length2 -gt $length ]]; 
then
  NEWLINE=$'\n'
  render="New anomalies detected DOT/USDT on Kucoin :${NEWLINE} Check it : "
  curl -s --data "text=$render" --data "chat_id=-1001811074866," 'https://api.telegram.org/bot5659403567:AAEsW1aNBOSf32F6w_xjQbJGPw3mS-iWDb8/sendMessage' > /dev/null
fi

