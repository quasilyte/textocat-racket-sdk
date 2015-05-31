#lang racket

(require "../src/textocat.rkt")

(provide (prefix-out test: (combine-out
  *auth.token-1* *auth.token-2*
  *input.json-1* *input.json-2*)))

(define *auth.token-1* "-- AUTH TOKEN-1 --")
(define *auth.token-2* "-- AUTH TOKEN-2 --")

;; Input should be encoded in UTF-8

(define *input.json-1* "[{\"text\":\"
  Председатель совета директоров ОАО «МДМ Банк» Олег Вьюгин — о том, чему
  приведет обмен санкциями между Россией и Западом в следующем году.
  Беседовала Светлана Сухова.\"}]")

(define *input.json-2* "[{\"text\":\"
  Важна ли скорость компиляции?
  Бьёрн Страуструп и Мартин Одерски считают, что нет.\"}]")