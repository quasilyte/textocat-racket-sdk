#lang racket

(require "../src/batch.rkt" "../src/textocat.rkt")

(displayln (textocat:with-auth-token "-- AUTH TOKEN --"
  (λ () (batch:slurp "[{\"text\":\"
    Председатель совета директоров ОАО «МДМ Банк» Олег Вьюгин — о том, чему
    приведет обмен санкциями между Россией и Западом в следующем году.
    Беседовала Светлана Сухова.\"}]"))))