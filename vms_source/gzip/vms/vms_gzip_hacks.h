#pragma message disable questcompare
#pragma message disable questcompare1
#pragma message disable maylosedata3

#define optarg hide_optarg
#define getopt hide_getopt
#define __STDIO_UNLOCK_CHAR_IO
#include <vms_fake_path/stdio.h>

/* Found broken __ferror related macros on VMS 8.4 Alpha header files */
/* No easy way to determine if fixed, so just replace them */
#undef __feof_
#undef __ferror_
#undef __clearerr_

#define __feof_(stream) \
((*stream) ? (((unsigned int)((*(stream))->_flag) & _IOEOF) != 0): 0 )
#define __ferror_(stream) \
((*stream)? (((unsigned int)((*(stream))->_flag) & _IOERR) != 0) : 0 )
#define __clearerr_(stream) \
((*stream)? ((void)((*(stream))->_flag &= ~(_IOERR | _IOEOF))) : (void)0 )


static size_t vms_freadahead( FILE * stream) { return 0; }
#define __freadahead(stream) vms_freadahead(stream)

int __fpurge(FILE *fp);

static int __freading(void * stream) {return 0; }

static void __fseterr(FILE * fp) {
    struct _iobuf * stream;
    stream = (struct _iobuf *) fp;
    stream->_flag |= _IOERR;
}


/* Simple getrlimit_hack */
#include "vms_getrlimit_hack.h"

void vms_expand_args(int *old_argc, char **argv_ptr[]);

#define NO_SIZE_CHECK
#define RECORD_IO 1
#define casemap(c) tolow(c)
#define OS_CODE  0x02

#define OPTIONS_VAR "GZIP"
#define EXPAND(argc, argv) vms_expand_args(&argc, &argv);
/* #include <file.h> */

#undef optarg
#undef getopt

#include <vms_fake_path/string.h>

static vms_gnv_shell = -1;

static int is_gnv(void) {
    char * shell;
    if (vms_gnv_shell != -1) {
        return vms_gnv_shell;
    }
    shell = getenv("SHELL");
    if (shell == NULL) {
        vms_gnv_shell = 0;
    } else {
        vms_gnv_shell = 1;
    }
    return vms_gnv_shell;
}

/* todo: should check decc$features settings for some of these. */
static char vms_path_sep(void) {
    if (is_gnv()) {
        return '/';
    } else {
        return ']';
    }
}

#define PATH_SEP vms_path_sep()

static char vms_path_sep2(void) {
    if (is_gnv()) {
        return '/';
    } else {
        return ':';
    }
}

#define PATH_SEP2 vms_path_sep2()

static char vms_suffix_sep(void) {
    if (is_gnv()) {
        return 0;
    } else {
        return ';';
    }
}

#define SUFFIX_SEP vms_suffix_sep()

static const char * vms_z_suffix(void) {
    if (is_gnv()) {
        return ".gz";
    } else {
        return "-gz";
    }
}

#define Z_SUFFIX vms_z_suffix()

static const char * vms_part_sep() {
    if (is_gnv()) {
        return ".";
    } else {
        return "-";
    }
}

#define PART_SEP vms_part_sep()

static const char vms_test_multiple_dots() {
   if (is_gnv()) {
       return 0;
   } else {
       return 1;
   }
}

/* Need a #define MAKE_LEGAL_NAME make_simple_name() */

#define TEST_MULTIPLE_DOTS vms_test_multiple_dots()

#define NO_MULTIPLE_DOTS 1

static char * vms_getenv(const char * env_name) {
    char * name;
    char * name_opts;
    int is_shell;
    int env_name_len;
    char env_name_opts[256];

    if (env_name == NULL) {
        errno = EINVAL;
        return NULL;
    }
    if (strcmp(OPTIONS_VAR, env_name) != 0) {
        return getenv(env_name);
    }
    is_shell = is_gnv();
    name = getenv(env_name);
    env_name_len = strlen(env_name);
    name_opts = NULL;
    if (env_name_len < 250) {
        strncpy(env_name_opts, env_name, 256 - 5);
        env_name_opts[255-5] = 0;
        strcat(env_name_opts, "_opts");
        name_opts = getenv(env_name_opts);
    }
    if (is_shell) {
        /* DCL behavior, name_opts takes precedence */
        if (name_opts != NULL) {
            return name_opts;
        }
        /* Filter out foreign commands */
        if ((name != NULL) && (name[0] != '$')) {
            return name;
        }
    } else {
        /* GNV behavior, name takes precedence */
        if ((name != NULL) && (name[0] != '$')) {
            return name;
        }
        if (name_opts != NULL) {
            return name_opts;
        }
    }
    return NULL;
}

#define getenv vms_getenv

#define main original_main

