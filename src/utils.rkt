#lang racket

(require net/url)

(provide get-param http-code!)

;;; public [exported]

(define (get-param key val)
  (string-append key "=" val))

(define (http-code! port)
  (second (regexp-match #rx"HTTP/[^ ]+ ([0-9]+)" (purify-port port))))
