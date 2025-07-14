(provide repeat-n-times)

(define (repeat-n-times f n)
  (let loop ([i n])
    (when (> i 0)
      (f)
      (loop (- i 1)))))
