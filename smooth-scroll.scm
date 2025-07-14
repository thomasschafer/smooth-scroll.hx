(require "helix/components.scm")
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/static.scm")

(require "src/utils.scm")

(provide half-page-up-smooth
         half-page-down-smooth
         page-up-smooth
         page-down-smooth)

(define *active-scroll-id* 0)

(define (start-smooth-scroll direction size #:step [step 1])
  (set! *active-scroll-id* (+ *active-scroll-id* 1))
  (let ([my-scroll-id *active-scroll-id*]
        [scroll-fn (match direction
                     ['up scroll_up]
                     ['down scroll_down]
                     [_ (error "Invalid scroll direction" direction)])])
    (let loop ([remaining size])
      (when (> remaining 0)
        (repeat-n-times scroll-fn step)
        (enqueue-thread-local-callback (lambda ()
                                         (when (= my-scroll-id *active-scroll-id*)
                                           (loop (- remaining step)))))))))

(define (get-view-height)
  (let ([area (editor-focused-buffer-area)])
    (if area
        (- (area-height area) 2) ; TODO: is this correct?
        (error "Unable to retrieve buffer height"))))

(define (half-page-up-smooth)
  (start-smooth-scroll 'up (/ (get-view-height) 2)))

(define (half-page-down-smooth)
  (start-smooth-scroll 'down (/ (get-view-height) 2)))

; TODO: slow down based on initial scroll amount
(define (page-up-smooth)
  (start-smooth-scroll 'up (get-view-height)))

(define (page-down-smooth)
  (start-smooth-scroll 'down (get-view-height)))
