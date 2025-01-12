#!/bin/bash

#set -x
set -e

# URL для проверки
URL="http://localhost:8080/helloDoc/users"

# Количество запросов
REQUESTS=10

# Переменная для хранения суммарного времени ответов
TOTAL_TIME=0

for i in $(seq 1 $REQUESTS); do
    # Выполняем запрос и измеряем время
    TIME=$(curl -s -o /dev/null -w "%{time_total}\n" "$URL")
    
    # Добавляем время к общей сумме
    TOTAL_TIME=$((TOTAL_TIME + $(echo "$TIME" | awk '{print int($1 * 1000)}')))
done

# Вычисляем среднюю скорость ответа
AVERAGE_RESPONSE_TIME=$(($TOTAL_TIME / $REQUESTS))

# Выводим результат
echo "Средняя скорость ответа: ${AVERAGE_RESPONSE_TIME} мс"