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
#define GMP_GET_ARG_0 	   if (sv_derived_from(x, "Math::BigInt::GMP")) {\
			   IV tmp = SvIV((SV*)SvRV(x));\
			   TEMP = (mpz_t*) tmp;\
		  } else { croak("x is not of type Math::BigInt::GMP"); }
#define GMP_GET_ARG_1 	   if (sv_derived_from(y, "Math::BigInt::GMP")) {\
			   IV tmp = SvIV((SV*)SvRV(y));\
			   TEMP_1 = (mpz_t*) tmp;\
		  } else { croak("y is not of type Math::BigInt::GMP"); }
#define GMP_GET_ARGS_0_1   GMP_GET_ARG_0; GMP_GET_ARG_1;

##############################################################################
# _new() 

mpz_t *
_new(Class,x)
	SV*	x

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_str(*RETVAL, SvPV_nolen(x), 0);
  OUTPUT:
    RETVAL

##############################################################################
# _from_bin()

mpz_t *
_from_bin(Class,x)
	SV*	x

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_str(*RETVAL, SvPV_nolen(x), 0);
  OUTPUT:
    RETVAL

##############################################################################
# _from_hex()

mpz_t *
_from_hex(Class,x)
	SV*	x

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_str(*RETVAL, SvPV_nolen(x), 0);
  OUTPUT:
    RETVAL

##############################################################################
# _zero()

mpz_t *
_zero(Class)

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_ui(*RETVAL, 0);
  OUTPUT:
    RETVAL

##############################################################################
# _one()

mpz_t *
_one(Class)

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_ui(*RETVAL, 1);
  OUTPUT:
    RETVAL

##############################################################################
# _two()

mpz_t *
_two(Class)

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_ui(*RETVAL, 2);
  OUTPUT:
    RETVAL

##############################################################################
# _ten()

mpz_t *
_ten(Class)

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set_ui(*RETVAL, 10);
  OUTPUT:
    RETVAL


##############################################################################
# DESTROY() - free memory of a GMP number

void
DESTROY(n)
	mpz_t*	n

  PPCODE:
    mpz_clear(*n);
    free(n);

##############################################################################
# _num() - numify, return string so that atof() and atoi() can use it

SV *
_num(Class, n)
	mpz_t*	n
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
# _zeros() - return number of trailing zeros (in decimal form)

int
_zeros(Class,n)
	mpz_t*	n

  PREINIT:
    SV*	TEMP;
    int len;
    char *buf;
    char *buf_end;

  CODE:
    /* len is always >= 1, and might be off (greater) by one than real len */
    len = mpz_sizeinbase(*n, 10);
    TEMP = newSV(len);			/* alloc len +1 bytes */
    SvPOK_on(TEMP);			/* make an PV */
    buf = SvPVX(TEMP);			/* get ptr to storage */ 
    buf_end = buf + len - 1;		/* end of storage (-1)*/
    mpz_get_str(buf, 10, *n);		/* convert to decimal string */
    RETVAL = 0;
    if (*buf_end == 0)
      {
      buf_end--;			/* ptr to last real digit */
      len --;				/* got one shorter than expected */
      }
    if (len > 1)			/* '0' has not trailing zeross! */
      {
      while (len-- > 0)
        {
        if (*buf_end-- != '0')
  	  {
          break;
	  }
        RETVAL++;
        }
      }
  OUTPUT:
    RETVAL

##############################################################################
# _as_hex() - return ref to hexadecimal string (prefixed with 0x)

SV *
_as_hex(Class,n)
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
  OUTPUT:
    RETVAL

##############################################################################
# _as_bin() - return ref to binary string (prefixed with 0b)

SV *
_as_bin(Class,n)
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
  OUTPUT:
    RETVAL


##############################################################################
# _modpow() - ($n ** $exp) % $mod

mpz_t *
_modpow(Class, n, exp, mod)
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

void
_modinv(Class,x,y)
	mpz_t*	x
	mpz_t*	y

  PREINIT:
    int rc, sign;
    SV* s;
    mpz_t* RETVAL;
  PPCODE:
    NEW_GMP_MPZ_T_INIT;
    rc = mpz_invert(*RETVAL, *x, *y);
    EXTEND(SP, 2);	/* we return two values */
    if (rc == 0)
      {
      /* inverse doesn't exist, return value undefined */
      PUSHs ( &PL_sv_undef );
      PUSHs ( &PL_sv_undef );
      }
    else
      {
      /* inverse exists, get sign */
      sign = mpz_sgn (*RETVAL);
      /* absolute result */
      mpz_abs (*RETVAL, *RETVAL);
      PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)RETVAL));
      if (sign >= 0)
        {
        PUSHs ( &PL_sv_undef );	/* result is ok, keep it */
        }
      else
        {
	s = sv_newmortal();
	sv_setpvn (s, "+", 1);
        PUSHs ( s );		/* result must be negated */
        }
      }

##############################################################################
# _add() - add $y to $x in place

void
_add(Class,x,y)
	SV*	x
	SV*	y
  PREINIT:
	mpz_t* TEMP;  
	mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    mpz_add(*TEMP, *TEMP, *TEMP_1);
    PUSHs( x );


##############################################################################
# _inc() - modify x inline by doing x++

void
_inc(Class,x)
	SV*	x
  PREINIT:
	mpz_t* TEMP;  
  PPCODE:
    GMP_GET_ARG_0;	/* TEMP =  mpz_t(x)  */
    mpz_add_ui(*TEMP, *TEMP, 1);
    PUSHs( x );

##############################################################################
# _dec() - modify x inline by doing x--

void
_dec(Class,x)
	SV*	x
  PREINIT:
	mpz_t* TEMP;  
  PPCODE:
    GMP_GET_ARG_0;	/* TEMP =  mpz_t(x)  */
    mpz_sub_ui(*TEMP, *TEMP, 1);
    PUSHs( x );

##############################################################################
# _sub() - $x - $y
# $x is always larger than $y! So overflow/underflow can not happen here.
# Formerly this code was:
# # if ($_[3])
#    {
#    $_[2] = Math::BigInt::GMP::sub_two($_[1],$_[2]); return $_[2];
#    }
#  Math::BigInt::GMP::_sub_in_place($_[1],$_[2]);
#  }

void
_sub(Class,x,y, ...)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
        mpz_t* TEMP_2;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    if ( items == 4 && SvTRUE(ST(3)) ) 
      {
      /* return new(y - x) */ 
      /* need to create TEMP_2 or it will ssegfault */
      TEMP_2 = malloc (sizeof(mpz_t)); mpz_init(*TEMP_2);

      mpz_sub(*TEMP_2, *TEMP, *TEMP_1);

      PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)TEMP_2)); 
      /*PUSHs(sv_setref_pv(y, "Math::BigInt::GMP", (void*)TEMP_2)); */ 
      }
    else
      {
      /* x -= y */
      mpz_sub(*TEMP, *TEMP, *TEMP_1);
      PUSHs( x );
      }

##############################################################################
# _rsft()

void
_rsft(Class,x,y,base_sv)
	SV*	x
	SV*	y
	SV*	base_sv
  PREINIT:
	unsigned long	y_ui;
	mpz_t*	TEMP;
	mpz_t*	TEMP_1;
	mpz_t*	BASE;

  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */

    y_ui = mpz_get_ui(*TEMP_1);
    BASE = malloc (sizeof(mpz_t));
    mpz_init_set_ui(*BASE,SvUV(base_sv));

    mpz_pow_ui(*BASE, *BASE, y_ui); /* ">> 3 in base 4" => "x / (4 ** 3)" */
    mpz_div(*TEMP, *TEMP, *BASE);
    mpz_clear(*BASE);
    free(BASE);
    PUSHs( x );

##############################################################################
# _lsft()

void
_lsft(Class,x,y,base_sv)
	SV*	x
	SV*	y
	SV*	base_sv
  PREINIT:
	unsigned long	y_ui;
	mpz_t*	TEMP;
	mpz_t*	TEMP_1;
	mpz_t*	BASE;

  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */

    y_ui = mpz_get_ui(*TEMP_1);
    BASE = malloc (sizeof(mpz_t));
    mpz_init_set_ui(*BASE,SvUV(base_sv));

    mpz_pow_ui(*BASE, *BASE, y_ui); /* "<< 3 in base 4" => "x * (4 ** 3)" */
    mpz_mul(*TEMP, *TEMP, *BASE);
    mpz_clear(*BASE);
    free(BASE);
    PUSHs ( x );

##############################################################################
# _mul()

void
_mul(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    mpz_mul(*TEMP, *TEMP, *TEMP_1);
    PUSHs( x );

##############################################################################
# _div(): x /= y or (x,rem) = x / y
# was in perl:
#sub _div
#  {
#  i f (wantarray)
#    {
#    # return (a/b,a%b)
#    my $r;
#    ($_[1],$r) = Math::BigInt::GMP::bdiv_two($_[1],$_[2]);
#    return ($_[1], $r);
#    }
#  # return a / b
#  Math::BigInt::GMP::div_two($_[1],$_[2]);
#  }

void
_div(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
    mpz_t* TEMP;
    mpz_t* TEMP_1;
    mpz_t * rem;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    if (GIMME_V == G_ARRAY)
      {
      /* former bdiv_two() routine */
      rem = malloc (sizeof(mpz_t));
      mpz_init(*rem);
      mpz_tdiv_qr(*TEMP, *rem, *TEMP, *TEMP_1);
      EXTEND(SP, 2);
      PUSHs( x );
      PUSHs(sv_setref_pv(sv_newmortal(), "Math::BigInt::GMP", (void*)rem));
      }
    else
      {
      /* former div_two() routine */
      mpz_div(*TEMP, *TEMP, *TEMP_1);			/* x /= y */
      PUSHs( x );
      }

##############################################################################
# _mod() - x %= y

void
_mod(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    mpz_mod(*TEMP, *TEMP, *TEMP_1);
    PUSHs( x );

##############################################################################
# _acmp() - cmp two numbers

int
_acmp(Class,m,n)
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
_is_zero(Class,x)
	mpz_t *	x

  CODE:
    RETVAL = mpz_cmp_ui(*x, 0);
    if ( RETVAL != 0) { RETVAL = 0; } else { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _is_one()  

int
_is_one(Class,x)
	mpz_t *	x

  CODE:
    RETVAL = mpz_cmp_ui(*x, 1);
    if ( RETVAL != 0) { RETVAL = 0; } else { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _is_two()  

int
_is_two(Class,x)
	mpz_t *	x

  CODE:
    RETVAL = mpz_cmp_ui(*x, 2);
    if ( RETVAL != 0) { RETVAL = 0; } else { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _is_ten()  

int
_is_ten(Class,x)
	mpz_t *	x

  CODE:
    RETVAL = mpz_cmp_ui(*x, 10);
    if ( RETVAL != 0) { RETVAL = 0; } else { RETVAL = 1; }
  OUTPUT:
    RETVAL

##############################################################################
# _pow() - x **= y

void
_pow(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    mpz_pow_ui(*TEMP, *TEMP, mpz_get_ui( *TEMP_1 ) );
    PUSHs( x );

##############################################################################
# _gcd() - gcd(m,n)

mpz_t *
_gcd(Class,x,y)
	mpz_t*	x
	mpz_t*	y

  CODE:
    NEW_GMP_MPZ_T_INIT;
    mpz_gcd(*RETVAL, *x, *y);
  OUTPUT:
    RETVAL

##############################################################################
# _and() - m &= n

void
_and(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;	/* (TEMP, TEMP_1) = (x,y)  */
    mpz_and(*TEMP, *TEMP, *TEMP_1);
    PUSHs( x );


##############################################################################
# _xor() - m =^ n

void
_xor(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;   /* (TEMP, TEMP_1) = (x,y)  */
    mpz_xor(*TEMP, *TEMP, *TEMP_1);
    PUSHs( x );


##############################################################################
# _or() - m =| n

void
_or(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;   /* (TEMP, TEMP_1) = (x,y)  */
    mpz_ior(*TEMP, *TEMP, *TEMP_1);
    PUSHs( x );


##############################################################################
# _fac() - n! (factorial)

void
_fac(Class,x)
        SV*     x
  PREINIT:
        mpz_t* TEMP;
  PPCODE:
    GMP_GET_ARG_0;   /* TEMP = x */
    mpz_fac_ui(*TEMP, mpz_get_ui(*TEMP));
    PUSHs( x );


##############################################################################
# _copy()

mpz_t *
_copy(Class,m)
	mpz_t*	m

  CODE:
    NEW_GMP_MPZ_T;
    mpz_init_set(*RETVAL, *m);
  OUTPUT:
    RETVAL


##############################################################################
# _is_odd() - test for number being odd

int
_is_odd(Class,n)
	mpz_t*	n

  CODE:
   RETVAL = mpz_tstbit(*n,0);
  OUTPUT:
    RETVAL

##############################################################################
# _is_even() - test for number being even

int
_is_even(Class,n)
	mpz_t*	n

  CODE:
     RETVAL = ! mpz_tstbit(*n,0);
  OUTPUT:
    RETVAL

##############################################################################
# _sqrt() - square root

void
_sqrt(Class,x)
        SV*     x
  PREINIT:
        mpz_t* TEMP;
  PPCODE:
    GMP_GET_ARG_0;   /* TEMP = x */
    mpz_sqrt(*TEMP, *TEMP);
    PUSHs( x );


##############################################################################
# _root() - integer roots

void
_root(Class,x,y)
        SV*     x
        SV*     y
  PREINIT:
        mpz_t* TEMP;
        mpz_t* TEMP_1;
  PPCODE:
    GMP_GET_ARGS_0_1;   /* (TEMP, TEMP_1) = (x,y)  */
    mpz_root(*TEMP, *TEMP, mpz_get_ui(*TEMP_1));
    PUSHs( x );

