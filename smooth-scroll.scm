(require "helix/components.scm")
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/static.scm")

(provide half-page-up-smooth
         half-page-down-smooth
         page-up-smooth
         page-down-smooth)

(define (repeat-n-times f n)
  (let loop ([i n])
    (when (> i 0)
      (f)
      (loop (- i 1)))))

(define (scroll-loop direction remaining #:step [step 1])
  (let ([scroll-fn (match direction
                     ['up scroll_up]
                     ['down scroll_down]
                     [_ (error "Invalid scroll direction" direction)])])
    (let loop ([remaining remaining])
      (when (> remaining 0)
        (repeat-n-times scroll-fn step)
        (enqueue-thread-local-callback (lambda () (loop (- remaining step))))))))

(define (get-view-height)
  (let ([area (editor-focused-buffer-area)])
    (if area
        (- (area-height area) 2) ; TODO: is this correct?
        (error "Unable to retrieve buffer height"))))

(define (half-page-up-smooth)
  (scroll-loop 'up (/ (get-view-height) 2)))

(define (half-page-down-smooth)
  (scroll-loop 'down (/ (get-view-height) 2)))

; TODO: calculate step based on initial scroll amount
(define (page-up-smooth)
  (scroll-loop 'up (get-view-height) #:step 2))

(define (page-down-smooth)
  (scroll-loop 'down (get-view-height) #:step 2))
