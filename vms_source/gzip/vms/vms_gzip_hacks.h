#pragma message disable questcompare
#pragma message disable questcompare1

#include <vms_fake_path/stdio.h>

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

void vms_expand_args(int *old_argc, char **argv);

#define PATH_SEP ']'
#define PATH_SEP2 ':'
#define SUFFIX_SEP ';'
#define NO_MULTIPLE_DOTS
#define NO_SIZE_CHECK
#define Z_SUFFIX "-gz"
#define RECORD_IO 1
#define casemap(c) tolow(c)
#define OS_CODE  0x02
#define OPTIONS_VAR "GZIP_OPT"
#define EXPAND(argc,argv) vms_expand_args(&argc, argv);
/* #include <file.h> */

