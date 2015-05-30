#lang racket

(require net/url json "utils.rkt" "./textocat.rkt")

(provide (prefix-out batch: (combine-out
  queue request retrieve
  in-progress? finished? success? failed?
  sync
  sync-retrieve slurp)))

;;; private [unexported]

(define (status-is? batch status.assertion)
  (equal? status.assertion (hash-ref batch 'status)))

;;; public [exported]

(define (queue input.json) (textocat:batch-queue input.json))
(define (request batch) (textocat:batch-request batch))
(define (retrieve batch)
  (first (hash-ref (textocat:batch-retrieve (list batch)) 'documents)))

(define (in-progress? batch)
  (status-is? batch "IN_PROGRESS"))

(define (success? batch)
  (status-is? batch "SUCCESS"))

(define (finished? batch)
  (status-is? batch "FINISHED"))

(define (failed? batch)
  (status-is? batch "FAILED"))

(define (input-error? batch)
  (status-is? batch "INPUT_ERROR"))

(define (sync batch #:delay [delay textocat:*default.delay*])
  (let do-while ()
    (sleep delay)
    (set! batch (request batch))
    (when (in-progress? batch) (do-while)))
  batch)

(define (sync-retrieve batch #:delay [delay textocat:*default.delay*])
  (retrieve (sync batch)))

(define (slurp input.json #:delay [delay textocat:*default.delay*])
  (sync-retrieve (queue input.json)))
