# pymongo-api

## Как запустить приложение

Запускаем mongodb и приложение

```shell
./sharding-repl-cache/scripts/start.sh
```

## Как проверить приложение

`start.sh` выводит все данные в консоль, а также возможена проверка через браузер
по адресу:
[http://localhost:8080](http://localhost:8080)


## Расположение диаграм

Диаграммы расположены в папке diagrams и пронумерованы в соответствии с пунктами задания:

* [Задание 1. Планирование (diagram/task1.drawio )](diagram/task1.drawio)
* [Задание 5. Service Discovery и балансировка с API Gateway (diagram/task5.drawio)](diagram/task5.drawio)
* [Задание 6. CDN (diagram/task6.drawio)](diagram/task6.drawio)


## После проверки

удалить volumes и остановить инраструктуру можно через

```shell
./sharding-repl-cache/scripts/stop.sh
```
