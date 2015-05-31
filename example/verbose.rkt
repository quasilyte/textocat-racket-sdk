#lang racket

;; This example covers most usages in details, but if you can not wait
;; just look at `quickstart.rkt' for shorter one.

(require "../src/textocat.rkt" "../src/batch.rkt" "shared.rkt")

;; You can't continue without logging in.
(textocat:login test:*auth.token-1*)

;; Let us be serious, we are going to check service status before proceed:
(unless (textocat:online?) (raise "textocat is offline!"))

;; We can get status message as a string:
(define status-str (textocat:status))

;; Create a queue request, save batchId and batchStatus into `batch':
(define batch (batch:queue test:*input.json-1*))
;; Now lock while batchStatus is IN_PROGRESS checking updates every 1/4 second:
(set! batch (batch:sync batch #:delay 0.25))

;; Ask for the result, we know it is either SUCCESS or FAILED:
(define result (batch:retrieve batch))
(if (batch:success? result)
  (displayln result)
  (raise "textocat failed to process given collection!"))

;; ...could be written as:
; (displayln (batch:retrieve (batch:sync (batch:queue test:*input.json-1*))))

;; ...or even better:
; (displayln (batch:sync-retrieve (batch:queue test:*input.json-1*)))

;; ...why not like this:
; (displayln (batch:slurp test:*input.json-1*))

;; There is also keyword argument support in `retrieve' procedure,
;; so the example below will wait for one and a half second before `retrieve'.
; (displayln (batch:retrieve #:after 1.5 (batch:queue test:*input.json-1*)))

;; It is possible to retrieve more than 1 collection at once.
(define batch-2 (batch:sync (batch:queue test:*input.json-2*)))
(define both-results (textocat:batch-retrieve (list batch batch-2)))
(displayln both-results)

;; Alternative is not call `sync' on `batch-2'.
;; While calling to `batch-retrieve' in this case will lead to undefined
;; behaviour, but it is safe to invoke `textocat:batch-sync-retrieve'