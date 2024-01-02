import sys

from pair import *
from scheme_utils import *
from ucb import main, trace

import scheme_forms

##############
# Eval/Apply #
##############


def scheme_eval(expr, env, tail=None):  # Optional third argument is ignored
    """Evaluate Scheme expression EXPR in Frame ENV.

    >>> expr = read_line('(+ 2 2)')
    >>> expr
    Pair('+', Pair(2, Pair(2, nil)))
    >>> scheme_eval(expr, create_global_frame())
    4
    """
    # Evaluate atoms
    if scheme_symbolp(expr):
        return env.lookup(expr)
    elif self_evaluating(expr):
        return expr

    # All non-atomic expressions are lists (combinations)
    if not scheme_listp(expr):
        raise SchemeError('malformed list: {0}'.format(repl_str(expr)))
    first, rest = expr.first, expr.rest
    if scheme_symbolp(first) and first in scheme_forms.SPECIAL_FORMS:
        return scheme_forms.SPECIAL_FORMS[first](rest, env)
    elif not isinstance(first, Pair) and isinstance(env.lookup(first), MacroProcedure):
        # BEGIN OPTIONAL 1
        res = scheme_apply(env.lookup(first), rest, env)
        return scheme_eval(res,env)
        # END OPTIONAL 1
    else:
        # BEGIN PROBLEM 3
        res = expr.map(lambda x:scheme_eval(x,env=env))
        return scheme_apply(res.first, res.rest, env)
        # END PROBLEM 3


def scheme_apply(procedure, args, env):
    """Apply Scheme PROCEDURE to argument values ARGS (a Scheme list) in
    Frame ENV, the current environment."""
    validate_procedure(procedure)
    if not isinstance(env, Frame):
       assert False, "Not a Frame: {}".format(env)
    if isinstance(procedure, BuiltinProcedure):
        # BEGIN PROBLEM 2
        lst = []
        ptr = args
        while ptr is not nil:
            lst.append(ptr.first)
            ptr = ptr.rest
        if procedure.need_env:
            lst.append(env)
        # END PROBLEM 2
        try:
            # BEGIN PROBLEM 2
            return procedure.py_func(*lst)
            # END PROBLEM 2
        except TypeError as err:
            raise SchemeError('incorrect number of arguments: {0}'.format(procedure))
    elif isinstance(procedure, LambdaProcedure):
        # BEGIN PROBLEM 9
        new_frame = procedure.env.make_child_frame(procedure.formals,args)
        return eval_all(procedure.body,new_frame)
        # END PROBLEM 9
    elif isinstance(procedure, MuProcedure) or isinstance(procedure,MacroProcedure):
        # BEGIN PROBLEM 11
        new_frame = env.make_child_frame(procedure.formals,args)
        return eval_all(procedure.body,new_frame)
        # END PROBLEM 11
    else:
        assert False, "Unexpected procedure: {}".format(procedure)


def eval_all(expressions, env):
    """Evaluate each expression in the Scheme list EXPRESSIONS in
    Frame ENV (the current environment) and return the value of the last.

    >>> eval_all(read_line("(1)"), create_global_frame())
    1
    >>> eval_all(read_line("(1 2)"), create_global_frame())
    2
    >>> x = eval_all(read_line("((print 1) 2)"), create_global_frame())
    1
    >>> x
    2
    >>> eval_all(read_line("((define x 2) x)"), create_global_frame())
    2
    """
    # BEGIN PROBLEM 6
    res = None
    ptr = expressions
    while ptr is not nil:
        if ptr.rest is nil:
            res = scheme_eval(ptr.first,env,True)
        else:
            res =  scheme_eval(ptr.first, env)
        ptr = ptr.rest
    return res 
    # END PROBLEM 6


##################
# Tail Recursion #
##################

class Unevaluated:
    """An expression and an environment in which it is to be evaluated."""

    def __init__(self, expr, env):
        """Expression EXPR to be evaluated in Frame ENV."""
        self.expr = expr
        self.env = env


def complete_apply(procedure, args, env):
    """Apply procedure to args in env; ensure the result is not an Unevaluated."""
    validate_procedure(procedure)
    val = scheme_apply(procedure, args, env)
    if isinstance(val, Unevaluated):
        return scheme_eval(val.expr, val.env)
    else:
        return val


def optimize_tail_calls(unoptimized_scheme_eval):
    """Return a properly tail recursive version of an eval function.
    我们 61A Scheme 解释器的尾调用优化方式：
    解释器通常会构建一个新框架，
    然后用新框架替换当前框架。
    旧框架仍然存在，但解释器再也无法访问它（垃圾回收）因为在尾递归中旧的变量只会被用一次。
    在23fall里这道题有更详细的背景和解释
    同时在PPT中有需要进行修改的尾部上下文的位置介绍
    """
    def optimized_eval(expr, env, tail=False):
        """Evaluate Scheme expression EXPR in Frame ENV. If TAIL,
        return an Unevaluated containing an expression for further evaluation.
        """
        if tail and not scheme_symbolp(expr) and not self_evaluating(expr):
            return Unevaluated(expr, env)

        result = Unevaluated(expr, env)
        # BEGIN PROBLEM EC
        while isinstance(result, Unevaluated): 
            result = unoptimized_scheme_eval(result.expr, result.env)
        return result
        # END PROBLEM EC
    return optimized_eval

################################################################
# Uncomment the following line to apply tail call optimization #
################################################################

scheme_eval = optimize_tail_calls(scheme_eval)
