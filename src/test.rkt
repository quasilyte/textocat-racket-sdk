#lang racket

;; this example covers most usages in details, but if you can not wait
;; just look at `quickstart.rkt' for shorter one


(require
  ;; textocat -- main procedures (api methods: queue, request, etc.)
  "./textocat.rkt"
  ;; batch -- useful wrappers and utility procedures (like `slurp')
  "./batch.rkt")

;; input should be encoded in UTF-8
(define input.json "[{\"text\":\"
  Председатель совета директоров ОАО «МДМ Банк» Олег Вьюгин — о том, чему
  приведет обмен санкциями между Россией и Западом в следующем году.
  Беседовала Светлана Сухова.\"}]")

; (textocat:login "--- YOUR API KEY ---")
;; you can't continue without logging in
(textocat:login "23026a11-5a28-4c05-a57c-76e17e642329")

;; let us be serious, we are going to check service status before proceed:
(unless (textocat:online?) (raise "textocat is offline!"))

;; we can get status message as a string:
(define status-str (textocat:status))

;; create a queue request, save batchId and batchStatus into `batch':
(define batch (batch:queue input.json))
;; now lock while batchStatus is IN_PROGRESS:
(set! batch (batch:sync batch))

;; ask for the result, we know it is either SUCCESS or FAILED:
(define result (batch:retrieve batch))
(if (batch:success? result)
  (displayln result)
  (raise "textocat failed to process given collection!"))

;; could be written as:
; (displayln (batch:retrieve (batch:sync (batch:queue input.json))))

;; or even better:
; (displayln (batch:sync-retrieve (batch:queue input.json)))

;; why not like this:
; (displayln (batch:slurp input.json))

;; there is also keyword argument support in `retrieve' procedure,
;; so the example below will wait for one and a half second before `retrieve'.
; (displayln (batch:retrieve #:after 1.5 (batch:queue input.json)))

;; it is possible to retrieve more than 1 collection at once.
(define batch-2 (batch:sync (batch:queue input.json)))
(define both-results (textocat:batch-retrieve (list batch batch-2)))
(displayln both-results)

;; alternative is not call `sync' on `batch-2'.
;; while calling to `batch-retrieve' in this case will lead to undefined
;; behaviour it is safe to invoke `batch-sync-retrieve'