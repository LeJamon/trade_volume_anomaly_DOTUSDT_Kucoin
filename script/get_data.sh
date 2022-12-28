#!/bin/bash
#https://api.kucoin.com/api/v1/market/histories?symbol=PDEX-USDT

curl -o tempo.json  -X 'GET' 'https://api.kucoin.com/api/v1/market/histories?symbol=DOT-USDT' 

jq .data tempo.json > data.json

jq -c '.[]' data.json | while read -r line; do
  
  price=$(echo "$line" | jq -r '.price')
  size=$(echo "$line" | jq -r '.size')
  side=$(echo "$line" | jq -r '.side')
  time=$(echo "$line" | jq -r '.time')

  # Insert the values into the table
  sqlite3 ./../database/trade.db "INSERT OR IGNORE INTO Trades (price, size, side, time) VALUES ( '$price', '$size', '$side', '$time');"
done 
sqlite3 ./../database/trade.db "INSERT INTO data (time, sum_size, side) SELECT time, SUM(size), side
FROM Trades
GROUP BY time;"




