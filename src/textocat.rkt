#lang racket

(require net/url json "utils.rkt")

(provide (prefix-out textocat: (combine-out
  *home* *default.delay*
  login with-auth-token
  batch-queue batch-request batch-retrieve
  status online? offline?)))

;;; data section

(define *auth.param* #f)

(define *default.delay* 0.2)

(define *home* "http://api.textocat.com/")

(define *online.msg* "Service is online")
(define *offline.msg* "Service is unavailable")

(define *header* (list
  "Content-type: application/json"
  "Accept: application/json"))
(define *generic.codes* (hash
  "400" "Wrong format. Check response manually for information"
  "401" "Auth token is invalid"
  "403" "Not enought permissions"
  "500" "Internal service error"))
(define *queue.codes* (hash
  "402" "Month processing limit exceeded"
  "405" "Wrong http-method"
  "406" "Such input is unsupported"
  "413" "Input data size limit exceeded"
  "415" "Wrong mime-type. Check response manually for information"
  "429" "To many parallel connections"))
(define *request.codes* (hash
  "404" "Can not find batch by given id"))
(define *retrieve.codes* (hash
  "406" "Collection is not processed yet"
  "416" "Simultaneous collection request limit exceeded"))
(define *search.codes* (hash))
(define *spec.codes* (hash
  "queue" *queue.codes*
  "request" *request.codes*
  "retrieve" *retrieve.codes*
  "search" *search.codes*))

;;; private [unexported]

(define (auth-param)
  (if *auth.param*
    *auth.param*
    (raise "call `login' procedure first with your auth_token")))

(define (entity-dest-str dest get.param.list)
  (string-append *home* "entity/" dest "?" (string-join get.param.list "&")))

(define (entity-dest-url dest get.param.list)
  (string->url (entity-dest-str dest get.param.list)))

(define (batch-ids hash.list)
  (map (λ (h) (get-param "batch_id" (hash-ref h 'batchId))) hash.list))

(define (checkout-generic-hash-and another.hash code)
  (let ([generic.msg (hash-ref *generic.codes* code #f)]
    [spec.msg (hash-ref another.hash code #f)])
    (when generic.msg (raise generic.msg))
    (when spec.msg (raise spec.msg))))

(define (port-handler resource port)
  (let ([code (http-code! port)] [this.codes (hash-ref *spec.codes* resource)])
    (checkout-generic-hash-and this.codes code)
    (read-json port)))

(define (api-get-request resource . params)
  (call/input-url (entity-dest-url resource (cons (auth-param) params))
    get-impure-port (λ (port) (port-handler resource port))))

;;; public [exported]

(define (login auth.token)
  (set! *auth.param* (get-param "auth_token" auth.token)))

(define (with-auth-token auth.token actions.lambda)
  (let ([old-auth-param *auth.param*])
    (login auth.token)
    (begin0
      (actions.lambda)
      (set! *auth.param* old-auth-param))))

(define (batch-queue input.json)
  (call/input-url (entity-dest-url "queue" (list (auth-param)))
    (λ (dest) (post-impure-port dest (string->bytes/utf-8 input.json) *header*))
    (λ (port) (port-handler "queue" port))))

(define (batch-request batch)
  (api-get-request "request" (get-param "batch_id" (hash-ref batch 'batchId))))

(define (batch-retrieve batch.list #:after [delay 0])
  (sleep delay)
  (apply api-get-request "retrieve" (batch-ids batch.list)))

(define (search query)
  (api-get-request "search" (get-param "search_query" query)))

(define (status)
  (call/input-url (string->url (string-append *home* "status?" (auth-param)))
    get-impure-port (λ (port)
      (let ([code (http-code! port)])
        (if (equal? code "200")
          *online.msg*
          *offline.msg*)))))

(define (online?)
  (equal? (status) *online.msg*))

(define (offline?)
  (not (online?)))
