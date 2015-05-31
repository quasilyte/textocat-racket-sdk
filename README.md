# Unofficial Textocat Racket (PLT/Scheme) SDK

This is unofficial Racket SDK for [Textocat](http://textocat.com).

[Textocat API](http://docs.textocat.com/).

# Usage

First of all, require both source files and log in:

```scheme
(require "batch.rkt" "textocat.rkt")

(textocat:login "-- AUTH TOKEN --")
```

Service info can be requested with ease:

```
(displayln (textocat:status))
(displayln (if (textocat:offline?) "offline..." "online!"))

;; There is also `textocat:online?' function which is equal to
;; (not (textocat:offline?))
```

If you want to do single request, code below will do without<br>
explicit call to `textocat:login`.<br>
`textocat:with-auth-token` can also be used to begin<br>
another session which encapsulated inside passed lambda.

```scheme
;; Inner lambda can contain multiple actions.

(displayln (textocat:with-auth-token "-- AUTH TOKEN --"
  (λ () (batch:slurp "[{\"text\":\"
    Председатель совета директоров ОАО «МДМ Банк» Олег Вьюгин — о том, чему
    приведет обмен санкциями между Россией и Западом в следующем году.
    Беседовала Светлана Сухова.\"}]"))))

;; Here, after `textocat:with-auth-token', we have previous auth_token again.
```

```scheme
(define input.json-1 "[{\"text\":\"
  Председатель совета директоров ОАО «МДМ Банк» Олег Вьюгин — о том, чему
  приведет обмен санкциями между Россией и Западом в следующем году.
  Беседовала Светлана Сухова.\"}]")

(define input.json-2 "[{\"text\":\"
  Важна ли скорость компиляции?
  Бьёрн Страуструп и Мартин Одерски считают, что нет.\"}]")

;; Retrieve 2 (max is 50) collections at once:

(displayln (textocat:batch-sync-retrieve (list
  (batch:queue input.json-1)
  (batch:queue input.json-2))))
```

### TODO/ADD
  `tests`<br>
  `package distribution`<br>
