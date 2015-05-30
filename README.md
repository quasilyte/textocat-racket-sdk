# Unofficial Textocat Racket (PLT/Scheme) SDK

This is unofficial Racket SDK for [Textocat](http://textocat.com).

[Textocat API](http://docs.textocat.com/).

# Usage

```scheme
#lang racket

(require "./textocat.rkt" "./batch.rkt")

(define input.json #"[{\"text\":\"text you wish textocat to process\"}]")

(textocat:login "--- YOUR API KEY ---")

;;; let us be serious, we are going to check service status before proceed:
(unless (textocat:online?) (raise "textocat is offline!"))

;;; we can get status message as a string:
(define status (textocat:status))

;;; create a queue request, save batchId and batchStatus into `batch':
(define batch (batch:queue input.json))
;;; now lock while batchStatus is IN_PROGRESS:
(set! batch (batch:sync batch))
;;; ask for the result, we know it is either FINISHED or FAILED:
(define result (batch:retrieve batch))
(displayln result)

;;; could be written as:
;; (displayln (batch:retrieve (batch:sync (batch:queue input.json))))

;;; or even better:
;; (displayln (batch:sync-retrieve (batch:queue input.json)))

;;; why not like this:
;; (displayln (batch:slurp input.json))

;;; there is also keyword argument support in `retrieve' procedure,
;;; so the example below will wait for one and a half second before `retrieve'.
;; (displayln (batch:retrieve #:after 1.5 (batch:queue input.json)))
```

### TODO/ADD
  `tests`<br>
  `package distribution`<br>
