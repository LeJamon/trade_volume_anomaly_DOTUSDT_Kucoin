#!/bin/bash

avg=$(sqlite3 ./../database/trade.db "SELECT AVG(sum_size) FROM data")
size=$(sqlite3 ./../database/trade.db "SELECT COUNT(*) FROM data")
max=$(sqlite3 ./../database/trade.db "SELECT MAX(sum_size) FROM data")
min=$(sqlite3 ./../database/trade.db "SELECT MIN(sum_size) FROM data")

lowerQuartile=$(echo "($min + $avg) / 2" | bc)
upperQuartile=$(echo "($max + $avg) / 2" | bc)

echo $lowerQuartile
echo $upperQuartile
echo $avg

sqlite3 ./../database/trade.db "INSERT OR IGNORE INTO Anomalie SELECT sum_size, side, time FROM data WHERE sum_size> $upperQuartile ORDER BY sum_size LIMIT 5"


