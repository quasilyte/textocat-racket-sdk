#lang racket

(require net/url json "utils.rkt" "./textocat.rkt")

(provide (prefix-out batch: (combine-out
  queue request retrieve search
  sync
  sync-retrieve slurp)))

;;; data section

(define *default.delay* 0.2)
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

(define (checkout-generic-hash-and another.hash code)
  (let ([generic.msg (hash-ref *generic.codes* code #f)]
    [spec.msg (hash-ref another.hash code #f)])
    (when generic.msg (raise generic.msg))
    (when spec.msg (raise spec.msg))))

(define (entity-dest dest get.param.list)
  (string-append textocat:*home* "entity/" dest "?" (string-join get.param.list "&")))

(define (dest-with-auth resource)
  (string->url (entity-dest resource (list (textocat:auth-param)))))

(define (dest-with-auth+param resource param)
  (string->url (entity-dest resource
    (list (textocat:auth-param) param))))

(define (port-handler resource port)
  (let ([code (http-code! port)] [this.codes (hash-ref *spec.codes* resource)])
    (checkout-generic-hash-and this.codes code)
    (read-json port)))

(define (api-get-request resource param)
  (call/input-url (dest-with-auth+param resource param)
    get-impure-port (lambda (port) (port-handler resource port))))

;;; public [exported]

;; essential procedures

(define (queue input.json)
  (call/input-url (dest-with-auth "queue")
    (lambda (dest) (post-impure-port dest input.json *header*))
    (lambda (port) (port-handler "queue" port))))

(define (request batch)
  (api-get-request "request" (get-param "batch_id" (hash-ref batch 'batchId))))

(define (retrieve batch #:after [delay 0])
  (sleep delay)
  (api-get-request "retrieve" (get-param "batch_id" (hash-ref batch 'batchId))))

(define (search query)
  (api-get-request "search" (get-param "search_query" query)))

;; helper procedures

(define (sync batch #:delay [delay *default.delay*])
  (let do-while ()
    (sleep delay)
    (set! batch (request batch))
    (when (equal? "IN_PROGRESS" (hash-ref batch 'status)) (do-while)))
  batch)

;; convenient wrappers

(define (sync-retrieve batch #:delay [delay *default.delay*])
  (retrieve (sync batch)))

(define (slurp input.json #:delay [delay *default.delay*])
  (sync-retrieve (queue input.json)))
