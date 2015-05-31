#lang racket

(require net/url json "remote.rkt")

(provide (prefix-out batch: (combine-out
  queue request retrieve
  in-progress? finished? success? failed? input-error?
  sync sync-retrieve
  slurp)))

;;; Private [unexported]:

(define (status-is? batch status.assertion)
  (equal? status.assertion (hash-ref batch 'status)))

(define (with-batch-id batch dest)
  (api-get-request dest (get-param "batch_id" (hash-ref batch 'batchId))))

;;; Public [exported]:

(define (queue input.json)
  (call/input-url (entity-dest-url "queue" '())
    (λ (dest) (post-port-builder input.json dest))
    (λ (port) (port-handler "queue" port))))

(define (request batch)
  (with-batch-id batch "request"))

(define (retrieve batch #:after [delay 0])
  (sleep delay)
  (first (hash-ref (with-batch-id batch "retrieve") 'documents)))

(define (in-progress? batch)
  (status-is? batch "IN_PROGRESS"))

(define (finished? batch)
  (status-is? batch "FINISHED"))

(define (success? batch)
  (status-is? batch "SUCCESS"))

(define (failed? batch)
  (status-is? batch "FAILED"))

(define (input-error? batch)
  (status-is? batch "INPUT_ERROR"))

(define (sync batch #:delay [delay *default.delay*])
  (let do-while ()
    (sleep delay)
    (set! batch (request batch))
    (when (in-progress? batch) (do-while)))
  batch)

(define (sync-retrieve batch #:delay [delay *default.delay*])
  (retrieve (sync batch #:delay delay)))

(define (slurp input.json #:delay [delay *default.delay*])
  (sync-retrieve (queue input.json) #:delay delay))
