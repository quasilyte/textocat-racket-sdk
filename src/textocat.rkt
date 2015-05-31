#lang racket

(require net/url json "remote.rkt" "batch.rkt")

(provide (prefix-out textocat: (combine-out
  login with-auth-token
  batch-retrieve batch-sync-retrieve
  status online? offline?)))

;;; Data section:

(define *online.msg* "Service is online")
(define *offline.msg* "Service is unavailable")

;;; Private [unexported]:

(define (batch-ids hash.list)
  (map (λ (h) (get-param "batch_id" (hash-ref h 'batchId))) hash.list))

;;; Public [exported]:

(define (login auth.token)
  (auth-param-set! auth.token))

(define (with-auth-token auth.token actions.lambda)
  (let ([old-auth-param *auth.param*])
    (login auth.token)
    (begin0
      (actions.lambda)
      (auth-param-replace! old-auth-param))))

(define (batch-retrieve batch.list #:after [delay 0])
  (sleep delay)
  (apply api-get-request "retrieve" (batch-ids batch.list)))

(define (batch-sync-retrieve batch.list [delay *default.delay*])
  (batch-retrieve (for/list ([batch batch.list])
    (batch:sync batch))))

(define (search query)
  (api-get-request "search" (get-param "search_query" query)))

(define (status)
  (call/input-url (dest-url "status?")
    get-impure-port (λ (port)
      (let ([code (http-code! port)])
        (if (equal? code "200")
          *online.msg*
          *offline.msg*)))))

(define (online?)
  (equal? (status) *online.msg*))

(define (offline?)
  (not (online?)))
