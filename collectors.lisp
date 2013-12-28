(in-package :lisp-unit2)
(cl-interpol:enable-interpol-syntax)

(defgeneric head (l)
  (:method (l) (car l)))
(defgeneric tail (l)
  (:method (l) (car l)))
(defgeneric len (l)
  (:method (l) (length l)))

(defclass list-collector ()
  ((head :accessor head :initarg :head :initform nil)
   (tail :accessor tail :initarg :tail :initform nil)
   (len :accessor len :initarg :len :initform 0 )))

(defgeneric %collect (it object)
  (:method (it (o null))
    (%collect it (make-instance 'list-collector) ))
  (:method (it (o list-collector) &aux (c (cons it nil)))
    (incf (len o))
    (if (null (head o))
        (setf (head o) c (tail o) c)
        (setf (cdr (tail o)) c
              (tail o) c))
    o))

(defgeneric %collect-new (it object &key test key)
  (:method (it (o null) &key test key)
    (declare (ignore test key) )
    (%collect it (make-instance 'list-collector) ))
  (:method (it (o list-collector)
            &key (test #'eql) (key #'identity))
    (unless (member it (head o) :key key :test test)
      (%collect it (make-instance 'list-collector) ))
    o))

(defgeneric %decollect (it object &key test key)
  (:method (it (o null) &key (test #'eql) (key #'name))
    (declare (ignore it test key))
    nil)
  (:method (it (o list-collector) &key  (test #'eql) (key #'identity))
    (when (head o)
      (iter (for cons on (head o))
        (for (this . next) = cons)
        (for prev previous cons)
        (when (funcall test it (funcall key this))
          (cond
            ((null prev)
             (setf (head o) next))
            ((null next) (setf (cdr prev) nil
                               (tail o) prev))
            (t (setf (cdr prev) next)))
          )))
    o))

(defmacro %collect! (it place)
  `(setf ,place (%collect ,it ,place)))

(defmacro %collect-new! (it place &key (test '#'eql) (key '#'identity))
  `(setf ,place (%collect-new ,it ,place :test ,test :key ,key)))

(defmacro %decollect! (it place  &key  (test '#'eql) (key '#'identity))
  `(setf ,place (%decollect ,it ,place :test ,test :key ,key)))