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

(define (calculate-delay size)
  (cond
    [(>= size 40) 0]
    [(>= size 20) 1]
    [(>= size 10) 2]
    [else 3]))

(define (calculate-step size)
  (ceiling (/ size 50)))

(define (move_up_single)
  (begin
    ; TODO: only call `move_visual_line_up` if line 6 or greater
    (move_visual_line_up)
    (scroll_up)))

; TODO: don't do anything if at bottom of file
(define (move_down_single)
  (begin
    (move_visual_line_down)
    (scroll_down)))

(define (start-smooth-scroll direction size)
  (set! *active-scroll-id* (+ *active-scroll-id* 1))
  (let ([my-scroll-id *active-scroll-id*]
        [scroll-fn (match direction
                     ['up move_up_single]
                     ['down move_down_single]
                     [_ (error "Invalid scroll direction" direction)])]
        [step (calculate-step size)]
        [delay-ms (calculate-delay size)])
    (let loop ([remaining size])
      (when (> remaining 0)
        (repeat-n-times scroll-fn step)
        (enqueue-thread-local-callback-with-delay delay-ms
                                                  (lambda ()
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

(define (page-up-smooth)
  (start-smooth-scroll 'up (get-view-height)))

(define (page-down-smooth)
  (start-smooth-scroll 'down (get-view-height)))
