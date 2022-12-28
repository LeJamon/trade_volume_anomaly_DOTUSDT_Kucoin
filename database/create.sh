#!/bin/bash

sqlite3 trade.db  "CREATE TABLE Trades(price REAL, size REAL, side TEXT, time INT);"
sqlite3 trade.db  "CREATE TABLE Anomalie(size REAL, side TEXT, time INT);"
sqlite3 trade.db "CREATE TABLE data(id INTEGER PRIMARY KEY AUTOINCREMENT, sum_size REAL, side TEXT, time INT);"