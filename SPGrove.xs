//
// Copyright (C) 1997 Ken MacLeod
// See the file COPYING for distribution terms.
//
// $Id: SPGrove.xs,v 1.1.1.1 1997/10/05 15:20:49 ken Exp $
//

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

SV *sp_grove_new (char *type, char *arg);

MODULE = SGML::SPGrove		PACKAGE = SGML::SPGrove

SV *
new(type, arg)
    char *type
    char *arg
    CODE:
        RETVAL = sp_grove_new(type, arg);
    OUTPUT:
    RETVAL
