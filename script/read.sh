#!/bin/bash

sqlite3 ./../database/trade.db "SELECT * FROM Anomalie"

#sqlite3 trade.db "SELECT SUM(size), side, time
#FROM Trades
#GROUP BY time;"


