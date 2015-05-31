#lang racket

(require net/url json)

(provide
  *auth.param* *default.delay*
  get-param
  auth-param-set! auth-param-replace! http-code!
  dest-url entity-dest-url
  api-get-request
  post-port-builder port-handler)

;; Provides wrappers to `call/input-url' and GET-query building stuff.
;; It is not aimed to be generic and reusable outside `textocat' SDK.
;; The context is - textocat service, so this file is in closest
;; relation possible with `textocat.rkt'.
;;
;; Theoretically, user can require this package and invoke `auth-param-set!'
;; instead of `textocat:login'. Nothing bad about it.

;;; Data section:

(define *home* "http://api.textocat.com/")
(define *auth.param* #f)

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

;;; Private [unexported]:

(define (auth-param)
  (if *auth.param*
    *auth.param*
    (raise "call `textocat:login' procedure first with your auth_token")))

(define (checkout-status-code spec.codes code)
  (let ([generic.msg (hash-ref *generic.codes* code #f)]
    [spec.msg (hash-ref spec.codes code #f)])
    (when spec.msg (raise spec.msg))
    (when generic.msg (raise generic.msg))))

(define (dest-str dest get.param.list)
  (let ([param-str (string-join (cons (auth-param) get.param.list) "&")])
    (string-append *home* dest "?" param-str)))

(define (entity-dest-str dest get.param.list)
  (dest-str (string-append "entity/" dest) get.param.list))

;;; Public [exported]:

(define (get-param key val)
  (string-append key "=" val))

(define (auth-param-set! auth.token)
  (set! *auth.param* (get-param "auth_token" auth.token)))

(define (auth-param-replace! auth.param)
  (set! *auth.param* auth.param))

(define (http-code! port)
  (second (regexp-match #rx"HTTP/[^ ]+ ([0-9]+)" (purify-port port))))

(define (dest-url dest [get.param.list '()])
  (string->url (dest-str dest get.param.list)))

(define (entity-dest-url dest [get.param.list '()])
  (string->url (entity-dest-str dest get.param.list)))

(define (post-port-builder baggage dest)
  (post-impure-port dest (string->bytes/utf-8 baggage) *header*))

(define (port-handler resource port)
  (let ([code (http-code! port)] [this.codes (hash-ref *spec.codes* resource)])
    (checkout-status-code this.codes code)
    (read-json port)))

(define (api-get-request resource . params)
  (call/input-url (entity-dest-url resource params)
    get-impure-port (λ (port) (port-handler resource port))))
