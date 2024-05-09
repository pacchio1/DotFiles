#!/bin/bash



#NON FUNZIONA



# Utilizzo della CPU
echo "Utilizzo CPU: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')"

# Utilizzo della RAM
echo "Utilizzo RAM: $(free | awk '/Mem/{printf "%.2f%\n", ($3/($2-$7))*100}')"

# Spazio disponibile sul dispositivo
echo "Spazio libero: $(df -h / | awk '/\//{print $(NF-2)}')"

# Indirizzo IP pubblico
echo "Indirizzo IP pubblico: $(curl -s http://checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')"
