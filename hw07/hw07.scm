(define (cddr s) (cdr (cdr s)))

(define (cadr s) (car (cdr s)))

(define (caddr s) (car (cdr(cdr s))))

(define (ascending? asc-lst) 
    (if (null? (cdr asc-lst) ) 
        #t
        (if (> (car asc-lst) (cadr asc-lst))
			#f
			(ascending? (cdr asc-lst))
		)
	)
)
        

(define (square n) (* n n))

(define (pow base exp)
  (cond ((= exp 1) base)
        ((= exp 0) 1)
        ((= (remainder exp 2) 0) (square (pow base (/ exp 2))))
        (else (* base (square (pow base (/ (- exp 1) 2)))))
	)
)
