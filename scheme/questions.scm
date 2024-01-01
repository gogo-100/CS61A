(define (caar x) (car (car x)))
(define (cadr x) (car (cdr x)))
(define (cdar x) (cdr (car x)))
(define (cddr x) (cdr (cdr x)))

;; Problem 15
;; Returns a list of two-element lists
(define (enumerate s)
  ; BEGIN PROBLEM 15
	(my_enumerate s 0)
 )
 
 (define (my_enumerate s index)
  ; BEGIN PROBLEM 15
	(cond ((null? s) nil)
		  (else (cons (list index (car s))(my_enumerate (cdr s) (+ index 1)))))
 )
  ; END PROBLEM 15
  
(define (interleave lst1 lst2) 
	(cond ((null? lst1) lst2)
		  ((null? lst2) lst1)
		  (else (cons (car lst1) (cons (car lst2) (interleave (cdr lst1)(cdr lst2)))))
	)
)
;; Problem 16

;; Merge two lists LIST1 and LIST2 according to ORDERED? and return
;; the merged lists.
(define (merge ordered? list1 list2)
  ; BEGIN PROBLEM 16
  (cond ((null? list1) list2)
		  ((null? list2) list1)
		  ((ordered? (car list1) (car list2)) (cons (car list1) (merge ordered? (cdr list1) list2)))
		  (else (cons (car list2) (merge ordered? list1(cdr list2))))
	)
 )
  ; END PROBLEM 16

;; Optional Problem 2

;; Returns a function that checks if an expression is the special form FORM
(define (check-special form)
  (lambda (expr) (equal? form (car expr))))

(define lambda? (check-special 'lambda))
(define define? (check-special 'define))
(define quoted? (check-special 'quote))
(define let?    (check-special 'let))

;; Converts all let special forms in EXPR into equivalent forms using lambda
(define (let-to-lambda expr)
  (cond ((atom? expr)
         ; BEGIN OPTIONAL PROBLEM 2
			expr
         ; END OPTIONAL PROBLEM 2
         )
        ((quoted? expr)
         ; BEGIN OPTIONAL PROBLEM 2
          ;(let-to-lambda expr)
		  expr
         ; END OPTIONAL PROBLEM 2
         )
        ((or (lambda? expr)
             (define? expr))
			 ; '(lambda (x) a (let ((a x)) a))
         (let ((form   (car expr))    ;lambda
               (params (cadr expr))   ; (x)
               (body   (cddr expr)))  ;(a (let ((a x)) a))
           ; BEGIN OPTIONAL PROBLEM 2   (lambda (x) a ((lambda (a) a) x))
           (cons form (cons params (map let-to-lambda body)))
           ; END OPTIONAL PROBLEM 2
           ))
        ((let? expr)
         (let ((values (cadr expr)) ;(values ((a 1) (b 2)))
               (body   (cddr expr))) ;(body (+ a b))
           ; BEGIN OPTIONAL PROBLEM 2
		   ; ((lambda (a b) (+ a b)) 1 2)
		   ; zip values   ((a b) (1 2))
		   (cons (cons 'lambda (cons (car (zip values)) (map let-to-lambda body) )) (map let-to-lambda (cadr (zip values))))
		   ;(let-to-lambda (cadr (zip values)))
		   ; END OPTIONAL PROBLEM 2
           ))
        (else
         ; BEGIN OPTIONAL PROBLEM 2
         (cons (car expr) (map let-to-lambda (cdr expr)))
         ; END OPTIONAL PROBLEM 2
         )))

; Some utility functions that you may find useful to implement for let-to-lambda

(define (zip pairs)
	(list (map car pairs)(map cadr pairs)) 
)

