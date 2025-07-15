(require "helix/components.scm")
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/static.scm")
(require-builtin helix/core/text)

(require "src/utils.scm")

(provide half-page-up-smooth
         half-page-down-smooth
         page-up-smooth
         page-down-smooth)

(define *active-scroll-id* 0)

(define (at-end-of-document?)
  (let* ([doc-id (editor->doc-id (editor-focus))]
         [rope (editor->text doc-id)]
         [cursor-pos (cursor-position)]
         [doc-length (rope-len-chars rope)])
    (>= cursor-pos (- doc-length 1))))

(define (calculate-delay size)
  (cond
    [(>= size 60) 0]
    [(>= size 40) 1]
    [(>= size 20) 2]
    [(>= size 10) 5]
    [else 10]))

(define (calculate-step size)
  (ceiling (/ size 50)))

(define (move_up_single)
  (begin
    (move_visual_line_up)
    (scroll_up)))

(define (move_down_single)
  (begin
    (when (>= (get-current-line-number) 6)
      (scroll_down))
    (move_visual_line_down)))

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
      (when (and (> remaining 0) (not (and (eq? direction 'down) (at-end-of-document?))))
        (repeat-n-times scroll-fn step)
        (enqueue-thread-local-callback-with-delay delay-ms
                                                  (lambda ()
                                                    (when (= my-scroll-id *active-scroll-id*)
                                                      (loop (- remaining step)))))))))

(define (view-height)
  (let ([area (editor-focused-buffer-area)])
    (if area
        (- (area-height area) 2)
        (error "Unable to retrieve buffer height"))))

(define (half-view-height)
  (ceiling (/ (view-height) 2)))

(define (half-page-up-smooth)
  (start-smooth-scroll 'up (half-view-height)))

(define (half-page-down-smooth)
  (start-smooth-scroll 'down (half-view-height)))

(define (page-up-smooth)
  (start-smooth-scroll 'up (view-height)))

(define (page-down-smooth)
  (start-smooth-scroll 'down (view-height)))
