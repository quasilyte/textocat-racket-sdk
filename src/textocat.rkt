#lang racket

(require net/url "utils.rkt")

(provide (prefix-out textocat: (combine-out
  *home*
  login
  auth-param
  status
  online?
  offline?)))

;;; data section

(define *auth.param* #f)
(define *home* "http://api.textocat.com/")
(define *online.msg* "Service is online")
(define *offline.msg* "Service is unavailable")

;;; public [exported]

(define (login auth.token)
  (set! *auth.param* (get-param "auth_token" auth.token)))

(define (auth-param)
  (if *auth.param*
    *auth.param*
    (raise "call `login' procedure first with your auth_token")))

(define (status)
  (call/input-url (string->url (string-append *home* "status?" (auth-param)))
    get-impure-port (lambda (port)
      (let ([code (http-code! port)])
        (if (equal? code "200")
          *online.msg*
          *offline.msg*)))))

(define (online?)
  (equal? (status) *online.msg*))

(define (offline?)
  (not (online?)))
