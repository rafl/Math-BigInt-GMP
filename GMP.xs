#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "gmp.h"

/*
Math::BigInt::GMP XS code, largely based on Math::GMP, a Perl module for
high-speed arbitrary size integer calculations (C) 2000 James H. Turner
*/

MODULE = Math::BigInt::GMP		PACKAGE = Math::BigInt::GMP
PROTOTYPES: ENABLE

#define NEW_GMP_MPZ_T	   RETVAL = malloc (sizeof(mpz_t));
#define NEW_GMP_MPZ_T_INIT RETVAL = malloc (sizeof(mpz_t)); mpz_init(*RETVAL);

##############################################################################
# _new() 

mpz_t *
_new(class,x)
	SV*	class
	SV*	x
  INIT:
    SV* s;

  CODE:
    s = (SV*)SvRV(x);			/* ref to string, don't check ref */
    NEW_GMP_MPZ_T;
    mpz_init_set_str(*RETVAL, SvPV_nolen(s), 0);
  OUTPUT:
    RETVAL

##############################################################################
# _from_bin()

mpz_t *
_from_bin(class,x)
	SV*	class
	SV*	x
  INIT:
    SV* s;

  CODE:
    s = (SV*)SvRV(x);			/* ref to string, don't check ref */
    NEW_GMP_MPZ_T;
    mpz_init_set_str(*RETVAL, SvPV_nolen(s), 0);
  OUTPUT:
    RETVAL

##############################################################################
# _from_hex()

mpz_t *
_from_hex(class,x)
	SV*	class
	SV*	x
  INIT:
    SV* s;

  CODE:
    s = (SV*)SvRV(x);			/* ref to string, don't check ref */
    NEW_GMP_MPZ_T;
    mpz_init_set_str(*RETVAL, SvPV_nolen(s), 0);
  OUTPUT:
    RETVAL

##############################################################################
# _zero()

mpz_t *
_zero(class)
	SV* class

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_ui(*RETVAL, 0);
  OUTPUT:
    RETVAL

##############################################################################
# _one()

mpz_t *
_one(class)
	SV* class

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_ui(*RETVAL, 1);
  OUTPUT:
    RETVAL

##############################################################################
# destroy() 

void
destroy(n)
	mpz_t *n

  CODE:
    mpz_clear(*n);
    free(n);

##############################################################################
# __stringify() - used by _num

SV *
__stringify(n)
	mpz_t *	n
  PREINIT:
    int len;
    char *buf;
    char *buf_end;

  CODE:
    /* len is always >= 1, and might be off (greater) by one than real len */
    len = mpz_sizeinbase(*n, 10);
    RETVAL = newSV(len);		/* alloc len +1 bytes */
    SvPOK_on(RETVAL);
    buf = SvPVX(RETVAL);		/* get ptr to storage */ 
    buf_end = buf + len - 1;		/* end of storage (-1)*/
    mpz_get_str(buf, 10, *n);		/* convert to decimal string */
    if (*buf_end == 0)
      {
      len --;				/* got one shorter than expected */
      }
    SvCUR_set(RETVAL, len); 		/* so set real length */
  OUTPUT:
    RETVAL

##############################################################################
# __str() - return ref to string

SV *
_str(class,n)
	SV*	class
	mpz_t*	n

  PREINIT:
    int len;
    char *buf;
    char *buf_end;

  CODE:
    /* len is always >= 1, and might be off (greater) by one than real len */
    len = mpz_sizeinbase(*n, 10);
    RETVAL = newSV(len);		/* alloc len +1 bytes */
    SvPOK_on(RETVAL);			/* make an PV */
    buf = SvPVX(RETVAL);		/* get ptr to storage */ 
    buf_end = buf + len - 1;		/* end of storage (-1)*/
    mpz_get_str(buf, 10, *n);		/* convert to decimal string */
    if (*buf_end == 0)
      {
      len --;				/* got one shorter than expected */
      }
    SvCUR_set(RETVAL, len); 		/* so set real length */
    RETVAL = newRV_noinc(RETVAL);	/* return ref to string */
  OUTPUT:
    RETVAL

##############################################################################
# _as_hex() - return ref to hexadecimal string (prefixed with 0x)

SV *
_as_hex(class,n)
	SV* class
	mpz_t *	n

  PREINIT:
    int len;
    char *buf;
    
  CODE:
    /* len is always >= 1, and accurate (unlike in decimal) */
    len = mpz_sizeinbase(*n, 16) + 2;
    RETVAL = newSV(len);		/* alloc len +1 (+2 for '0x') bytes */
    SvPOK_on(RETVAL);
    buf = SvPVX(RETVAL);		/* get ptr to storage */
    *buf++ = '0'; *buf++ = 'x';		/* prepend '0x' */
    mpz_get_str(buf, 16, *n);		/* convert to hexadecimal string */
    SvCUR_set(RETVAL, len); 		/* so set real length */
    RETVAL = newRV_noinc(RETVAL);	/* return ref to string */
  OUTPUT:
    RETVAL

##############################################################################
# _as_bin() - return ref to binary string (prefixed with 0b)

SV *
_as_bin(class,n)
	SV*	class
	mpz_t *	n

  PREINIT:
    int len;
    char *buf;
    
  CODE:
    /* len is always >= 1, and accurate (unlike in decimal) */
    len = mpz_sizeinbase(*n, 2) + 2;
    RETVAL = newSV(len);		/* alloc len +1 (+2 for '0b') bytes */
    SvPOK_on(RETVAL);
    buf = SvPVX(RETVAL);		/* get ptr to storage */ 
    *buf++ = '0'; *buf++ = 'b';		/* prepend '0b' */
    mpz_get_str(buf, 2, *n);		/* convert to binary string */
    SvCUR_set(RETVAL, len); 		/* so set real length */
    RETVAL = newRV_noinc(RETVAL);	/* return ref to string */
  OUTPUT:
    RETVAL


##############################################################################
# _modpow() - ($n ** $exp) % $mod

mpz_t *
_modpow(class, n, exp, mod)
       SV*	class
       mpz_t*	n
       mpz_t*	exp
       mpz_t*	mod

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_powm(*RETVAL, *n, *exp, *mod);
  OUTPUT:
    RETVAL

##############################################################################
# _modinv() - compute the inverse of x % y
#
# int mpz_invert (mpz_t rop, mpz_t op1, mpz_t op2) 	Function
# Compute the inverse of op1 modulo op2 and put the result in rop. If the
# inverse exists, the return value is non-zero and rop will satisfy
# 0 <= rop < op2. If an inverse doesn't exist the return value is zero and rop
# is undefined.

#mpz_t *
#_modinv(class,x,y)
#       SV*	class
#       mpz_t*	x
#       mpz_t*	y
#
#  PREINIT:
#    int rc;
#    int sign;
#  CODE:
#    NEW_GMP_MPZ_T_INIT;
#    rc = mpz_invert(*RETVAL, *x, *y);
#    #if (rc == 0)
#      {
#      /* inverse doesn't exist, return value undefined */
#      }
#    #else
#      {
#      /* inverse exists, get sign */
#      sign = mpz_sgn (*RETVAL);
#      /* absolute result */
#      mpz_abs (*RETVAL, *RETVAL);
#      }
#  EXTEND(SP, 2);
#  PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)RETVAL));
#  PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)sign));

##############################################################################
# _add()

mpz_t *
_add(class,x,y)
	SV*	class
	mpz_t *	x
	mpz_t *	y

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_add(*RETVAL, *x, *y);
    mpz_set(*x, *RETVAL);
  OUTPUT:
    RETVAL


##############################################################################
# _inc()

mpz_t *
_inc(class,x)
	SV*	class
	mpz_t*	x

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_add_ui(*RETVAL, *x, 1);
    mpz_set(*x, *RETVAL);
  OUTPUT:
    RETVAL

##############################################################################
# _dec()

mpz_t *
_dec(class,x)
	SV*	class
	mpz_t*	x

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_sub_ui(*RETVAL, *x, 1);
    mpz_set(*x, *RETVAL);
  OUTPUT:
    RETVAL


##############################################################################
# _sub_two()

mpz_t *
sub_two(m,n)
	mpz_t *		m
	mpz_t *		n

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_sub(*RETVAL, *m, *n);
  OUTPUT:
    RETVAL


##############################################################################
# _rsft()

mpz_t *
_rsft(class,x,y,base_sv)
	SV*	class
	mpz_t*	x
	mpz_t*	y
	SV*	base_sv
  PREINIT:
	unsigned long	y_ui;
	mpz_t*	TEMP;
	mpz_t*	BASE;

  CODE:
    NEW_GMP_MPZ_T_INIT;
    TEMP = malloc (sizeof(mpz_t));
    mpz_init(*TEMP);
    y_ui = mpz_get_ui(*y);
    BASE = malloc (sizeof(mpz_t));
    mpz_init_set_ui(*BASE,SvUV(base_sv));
    mpz_pow_ui(*TEMP, *BASE, y_ui); /* ">> 3 in base 4" => "x / (4 ** 3)" */
    mpz_div(*RETVAL, *x, *TEMP);
    mpz_clear(*TEMP);
    free(TEMP);
    mpz_clear(*BASE);
    free(BASE);
  OUTPUT:
    RETVAL

##############################################################################
# _lsft()

mpz_t *
_lsft(class,x,y,base_sv)
	SV*	class
	mpz_t*	x
	mpz_t*	y
	SV*	base_sv
  PREINIT:
	unsigned long	y_ui;
	mpz_t*	TEMP;
	mpz_t*	BASE;

  CODE:
    NEW_GMP_MPZ_T_INIT;
    TEMP = malloc (sizeof(mpz_t));
    mpz_init(*TEMP);
    y_ui = mpz_get_ui(*y);
    BASE = malloc (sizeof(mpz_t));
    mpz_init_set_ui(*BASE,SvUV(base_sv));
    mpz_pow_ui(*TEMP, *BASE, y_ui); /* ">> 3 in base 4" => "x / (4 ** 3)" */
    mpz_mul(*RETVAL, *x, *TEMP);
    mpz_clear(*TEMP);
    free(TEMP);
    mpz_clear(*BASE);
    free(BASE);
  OUTPUT:
    RETVAL

##############################################################################
# _mul()

mpz_t *
_mul(class,x,y)
	SV*	class
	mpz_t*	x
	mpz_t*	y

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_mul(*RETVAL, *x, *y);
    mpz_set(*x, *RETVAL);
  OUTPUT:
    RETVAL


##############################################################################
# _div_two()

mpz_t *
div_two(m,n)
	mpz_t *		m
	mpz_t *		n

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_div(*RETVAL, *m, *n);
  OUTPUT:
    RETVAL


##############################################################################
# _bdiv_two()

void
bdiv_two(m,n)
	mpz_t *		m
	mpz_t *		n

  PREINIT:
    mpz_t * quo;
    mpz_t * rem;
  PPCODE:
    quo = malloc (sizeof(mpz_t));
    rem = malloc (sizeof(mpz_t));
    mpz_init(*quo);
    mpz_init(*rem);
    mpz_tdiv_qr(*quo, *rem, *m, *n);
  EXTEND(SP, 2);
  PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)quo));
  PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)rem));


##############################################################################
# _mod()

mpz_t *
_mod(class,x,y)
	SV*	class
	mpz_t*	x
	mpz_t*	y

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_mod(*RETVAL, *x, *y);
    mpz_set(*x, *RETVAL);
  OUTPUT:
    RETVAL

##############################################################################
# _acmp() - cmp two numbers

int
_acmp(class,m,n)
	SV*	class
	mpz_t *	m
	mpz_t *	n

  CODE:
    RETVAL = mpz_cmp(*m, *n);
    if ( RETVAL < 0) { RETVAL = -1; }
    if ( RETVAL > 0) { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _is_zero()  

int
_is_zero(class,x)
	SV*	class
	mpz_t *	x

  CODE:
    RETVAL = mpz_cmp_ui(*x, 0);
    if ( RETVAL != 0) { RETVAL = 0; } else { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _is_one()  

int
_is_one(class,x)
	SV*	class
	mpz_t *	x

  CODE:
    RETVAL = mpz_cmp_ui(*x, 1);
    if ( RETVAL != 0) { RETVAL = 0; } else { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _pow() - m ** n

mpz_t *
_pow(class,x,y)
	SV*	class
	mpz_t*	x
	mpz_t*	y

  PREINIT:
	unsigned long	yui;
  CODE:
    NEW_GMP_MPZ_T_INIT;
    yui = mpz_get_ui(*y);
    mpz_pow_ui(*RETVAL, *x, yui);
    mpz_set(*x, *RETVAL);
  OUTPUT:
    RETVAL

##############################################################################
# _gcd() - gcd(m,n)

mpz_t *
_gcd(class,x,y)
	SV*	class
	mpz_t*	x
	mpz_t*	y

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_gcd(*RETVAL, *x, *y);
  OUTPUT:
    RETVAL

##############################################################################
# _and() - m & n

mpz_t *
_and(class,m,n)
	SV*	class
	mpz_t*	m
	mpz_t*	n

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_and(*RETVAL, *m, *n);
  OUTPUT:
    RETVAL

##############################################################################
# _xor() - m ^ n

mpz_t *
_xor(class,m,n)
	SV*	class
	mpz_t*	m
	mpz_t*	n

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_xor(*RETVAL, *m, *n);
  OUTPUT:
    RETVAL


##############################################################################
# _or() - m | n

mpz_t *
_or(class,m,n)
	SV*	class
	mpz_t*	m
	mpz_t*	n

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_ior(*RETVAL, *m, *n);
  OUTPUT:
    RETVAL


##############################################################################
# _fac() - n! (factorial)

mpz_t *
_fac(class,n)
	SV*	class
	mpz_t*	n
  PREINIT:
    unsigned long nui;

  CODE:
    NEW_GMP_MPZ_T_INIT;
    nui = mpz_get_ui(*n);
    mpz_fac_ui(*RETVAL, nui);
    mpz_set(*n, *RETVAL);
  OUTPUT:
    RETVAL


##############################################################################
# _copy()

mpz_t *
_copy(class,m)
        SV*		class
	mpz_t *		m

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set(*RETVAL, *m);
  OUTPUT:
    RETVAL


##############################################################################
# _is_odd() - test for number beeing odd

int
_is_odd(class,n)
        SV*		class
	mpz_t *		n

  CODE:
   RETVAL = mpz_tstbit(*n,0);
  OUTPUT:
    RETVAL

##############################################################################
# _is_even() - test for number beeing even

int
_is_even(class,n)
        SV*		class
	mpz_t *		n

  CODE:
     RETVAL = ! mpz_tstbit(*n,0);
  OUTPUT:
    RETVAL

##############################################################################
# _sqrt() - square root

mpz_t *
_sqrt(class,x)
        SV*		class
	mpz_t *		x

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_sqrt(*RETVAL, *x);
  OUTPUT:
    RETVAL

##############################################################################
# _root() - integer roots

mpz_t *
_root(class,x,y)
        SV*		class
	mpz_t *		x
	mpz_t *		y
  PREINIT:
    unsigned long nui;

  CODE:
    NEW_GMP_MPZ_T_INIT;
    nui = mpz_get_ui(*y);
    mpz_root(*RETVAL, *x, nui);
  OUTPUT:
    RETVAL


##############################################################################
# _log_int() - integer log of $x to base $base

void
_log_int(class,x,base)
        SV*		class
	mpz_t *		x
	mpz_t *		base
  
  PREINIT:
    mpz_t *		trial;
    mpz_t *		RETVAL;

  CODE:
    NEW_GMP_MPZ_T_INIT;

  /* this trial multiplication is very fast, even for large counts (like for 
     2 ** 1024, since this still requires only 1024 very fast steps
     (multiplication of a large number by a very small number is very fast)) */

    mpz_init_set_ui(*RETVAL,0);
    trial = malloc (sizeof(mpz_t));
    mpz_init(*trial);
    mpz_set(*trial, *base);
     
    while ( mpz_cmp(*trial, *x) <= 0)
      {
      mpz_mul(*trial, *trial, *base); mpz_add_ui(*RETVAL,*RETVAL,1);
      }
    mpz_clear (*trial);
    free (trial);
    mpz_set (*x, *RETVAL);
    mpz_clear (*RETVAL);
    free (RETVAL);
  /* return X and undef (don't know whether result is exact)
     XXX TODO compute exact */
  EXTEND(SP, 2);
  PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)x));
  PUSHs(newSViv(0));


