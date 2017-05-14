/* vms_expand_args.c -- target dependent functions for VMS
 * This is free software; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License, see the file COPYING.
 *
 * This file was based on vms_expand_args.h found in the original GNV
 * modified source for an older gzip port.  The current gzip source
 * references this routine, but does not provide it.
 * Original vms_expand_args.h was
 * written by Karl-Jose Filler <pla_jfi@pki-nbg.philips.de>
 * and updated by Jean-loup Gailly.
 *
 * John E. Malmberg <wb8tyw@qsl.net> changes:
 *   * Build as standalone module.
 *   * Use VMS header files for symbols and structures.
 *   * 64 bit pointer support.
 *   * Remove memory leaks
 *   * Long filename support.
 *   * Make argv usage more clear.
 *   * Enable DECC$FILE_SHARING needed for gzip 1.7
 */

/* Gnu projects now include header files with the same name as
 * OS provided system headers.  On VMS this hack of using a
 * non-existent path is needed to get the OS provided system headers.
 */

#include <vms_fake_path/stdlib.h>
#include <vms_fake_path/stdio.h>
#include <vms_fake_path/string.h>
#include <vms_fake_path/unixlib.h>

#include <vms_fake_path/stsdef.h>
#include <vms_fake_path/libfildef.h>
#include <vms_fake_path/descrip.h>
#include <vms_fake_path/namdef.h>

int find_file_c(char * in, char * out, int out_len, unsigned long *context);

#define lib$find_file LIB$FIND_FILE
#define lib$find_file_end LIB$FIND_FILE_END

#if __INITIAL_POINTER_SIZE
#define dsc_descriptor_s dsc64$descriptor_s
#define dsc_length dsc64$q_length
#define dsc_pointer dsc64$pq_pointer
#define dsc_from_string(my_desc, my_string) \
    my_desc.dsc64$w_mbo = 1; \
    my_desc.dsc64$l_mbmo = -1; \
    my_desc.dsc64$pq_pointer = my_string; \
    my_desc.dsc64$q_length = strlen(my_string); \
    my_desc.dsc64$b_dtype = DSC$K_DTYPE_T; \
    my_desc.dsc64$b_class = DSC$K_CLASS_S;
#define dsc_to_string(my_desc, my_string, my_len) \
    my_desc.dsc64$w_mbo = 1; \
    my_desc.dsc64$l_mbmo = -1; \
    my_desc.dsc64$pq_pointer = my_string; \
    my_desc.dsc64$q_length = my_len; \
    my_desc.dsc64$b_dtype = DSC$K_DTYPE_T; \
    my_desc.dsc64$b_class = DSC$K_CLASS_S;
#else
#define dsc_descriptor_s dsc$descriptor_s
#define dsc_length dsc$w_length
#define dsc_pointer dsc$a_pointer
#define dsc_from_string(my_desc, my_string) \
    my_desc.dsc$a_pointer = my_string; \
    my_desc.dsc$w_length = strlen(my_string); \
    my_desc.dsc$b_dtype = DSC$K_DTYPE_T; \
    my_desc.dsc$b_class = DSC$K_CLASS_S;
#define dsc_to_string(my_desc, my_string, my_len) \
    my_desc.dsc$a_pointer = my_string; \
    my_desc.dsc$w_length = my_len; \
    my_desc.dsc$b_dtype = DSC$K_DTYPE_T; \
    my_desc.dsc$b_class = DSC$K_CLASS_S;
#endif

int lib$find_file(
  const struct dsc_descriptor_s * filespec,
  const struct dsc_descriptor_s * resultspec,
  unsigned long * context,
  const struct dsc_descriptor_s * defspec,
  const struct dsc_descriptor_s * relspec,
  unsigned long * statusv,
  const unsigned long * flags);

int lib$find_file_end(const unsigned long * context);

static char **vms_argv = NULL;

#ifdef NAML$C_MAXRSS
#define MAX_FILENAME_LEN (NAML$C_MAXRSS + 1)
#else
#define MAX_FILENAME_LEN (NAM$C_MAXRSS + 1)
#endif

static int max_files = 10000;

void vms_expand_args(old_argc, argv_ptr)
    int *old_argc;
    char **argv_ptr[];
{
    int	    i;
    int	    new_argc = 0;
    char    buf[MAX_FILENAME_LEN], *p;
    char    **argv;

    argv = argv_ptr[0];
    decc$feature_set("DECC$FILE_SHARING", __FEATURE_MODE_CURVAL, 1);
    vms_argv = malloc((max_files + 1) * sizeof(char*));

    vms_argv[new_argc++] = *argv;

    for (i=1; i < *old_argc; i++) {
	if (argv[i][0] == '-') {   /* switches */
	    if (new_argc < max_files) {
		vms_argv[new_argc++] = argv[i];
	    }
	} else {		    /* Files */
            unsigned long context;
	    int status;
	    context = 0;
            status = find_file_c(argv[i], buf, sizeof(buf), &context);
	    if ($VMS_STATUS_SUCCESS(status)) {
		/*
	         * Wrong file ?
		 * forward it to gzip
		 */
		if (new_argc < max_files) {
		    vms_argv[new_argc++] = strdup(argv[i]);
		}
	    } else {
		if (new_argc < max_files) {
		    vms_argv[new_argc++] = strdup(buf);
		}
                status = find_file_c(argv[i], buf, sizeof(buf), &context);
		while ($VMS_STATUS_SUCCESS(status)) {
		    if (new_argc < max_files) {
			vms_argv[new_argc++] = strdup(buf);
		    }
		}
	    }
            lib$find_file_end(&context);
	}
    }
    if (new_argc <= max_files) {
	*old_argc = new_argc;
	vms_argv[new_argc] = NULL;
	*argv_ptr = vms_argv;
    } else {
        for (i=1; i < *old_argc; i++) {
	    if (*argv[i] != '-') {   /* switches */
                free(argv[i]);
            }
        }
	free(vms_argv); /* the expanded file names should also be freed ... */
	vms_argv = NULL;
	max_files = new_argc + 100;
	vms_expand_args(old_argc, argv);
    }
}

int find_file_c(in, out, out_len, context)
    char *in;
    char *out;
    int   out_len;
    unsigned long *context;
{
    struct	dsc_descriptor_s in_desc,out_desc;
    int		status;
    char	*p;
    unsigned long flags = 0;

#ifndef __VAX
    flags = LIB$M_FIL_LONG_NAMES;
#endif

    dsc_from_string(in_desc, in)
    dsc_to_string(out_desc, out, out_len)

    status = lib$find_file(&in_desc, &out_desc, context,
                           NULL, NULL, NULL, &flags);

    if ($VMS_STATUS_SUCCESS(status)) {
        p   = out_desc.dsc_pointer;
        while(*p != ' ') {
	    p++;
	}
        *p = 0;
    }

    return status;
}
