#!/usr/bin/env bash
while [ true ]
do 
    echo -en 'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<h1>Hello World!</h1>' | nc -lvp 3000;
done