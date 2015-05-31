#lang racket

(require "../src/batch.rkt" "../src/textocat.rkt" "shared.rkt")

(textocat:login test:*auth.token-1*)

(displayln (textocat:status))
(displayln (if (textocat:offline?) "offline..." "online!"))

;; There is also `textocat:online?' function which is equal to
;; (not (textocat:offline?))