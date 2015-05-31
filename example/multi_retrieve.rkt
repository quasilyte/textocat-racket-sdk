#lang racket

(require "../src/batch.rkt" "../src/textocat.rkt" "shared.rkt")

(textocat:login test:*auth.token-1*)

;; Retrieve 2 collections at once:

(displayln (textocat:batch-sync-retrieve (list
  (batch:queue test:input.json-1)
  (batch:queue test:input.json-2))))