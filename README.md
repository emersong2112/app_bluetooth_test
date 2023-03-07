# Bluetooth Tracker

App de exemplo de modelo de gerenciamento de controle de fluxo de pessoas.

O objetivo desse app é ser uma Prova de Conceito (POC), demonstrando que é possível e viável ter um controle preciso e em tempo real do número de pessoas que passam por um determinado local utilizando esse app.

A cada 10 segundos, ele escaneia o ambiente, guargando os endereços MAC de todos os dispositivos encontrados e armazena em uma lista, comparando com os últimos scans para saber quais são novos e quais são recorrentes.

Dessa forma sabemos quantas visitas únicas houveram e quantos estão visíveis agora.

Esse app foi criado em flutter e utiliza o pacote flutter_blue_plus para acessar o bluetooth do dispositivo.
