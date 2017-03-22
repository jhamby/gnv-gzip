$! VMS_PREBUILD.COM
$!
$! This script sets up everything needed to run the Bash configure script
$! and subsequent makefile
$!
$! 03-Jul-2016	J. Malmberg
$!
$!=======================================================================
$ cstand = "/standard=(relaxed,isoc94)"
$ caccept = "/accept=(novaxc,restr,c99)"
$ prefix = "/prefix=except=(strtoimax,strtoumax,iswblank)"
$ clist = "/list/show=(expan,inclu)"
$ cname = "/names=(as_is,short)/main=posix_exit"
$ cfloat = "/float=IEEE/IEEE_MODE=DENORM_RESULTS"
$ cinc = "/nested=NONE"
$ cc :== cc'cstand''caccept''clist''cname''cfloat''cinc''prefix'/debug
$ cc :== 'cc'/pointer_size=long=argv
$ defdir = f$environment("default")
$ defdir_base = defdir - "]" - ">"
$ delim = f$extract(f$length(defdir) -1, 1, defdir)
$ define decc$user_include 'defdir_base'.vms'delim'
$ my_dir = f$parse(defdir,,, "DIRECTORY")
$ my_dir_name = my_dir - "[" - "]" - "<" - ">"
$ set proc/parse=extended
$!
$ if p1 .eqs. "DEBUG"
$ then
$   cc :== 'cc'/debug/nooptimize
$   link :== link/threads_enable/debug
$ else
$   if f$type(link) .eqs. "STRING"
$   then
$       del/sym/glo link
$   endif
$   link :== link/threads_enable
$ endif
$!
$! CRTL pre-init
$!----------------
$ if f$search("vms_crtl_init.obj") .eqs. ""
$ then
$   cc/object=sys$disk:[]vms_crtl_init.obj -
        [.vms]vms_crtl_init.c
$ endif
$!
$! Special wildcard init hack
$! File was found with name vms_expand_args.h
$ if f$search("vms_expand_args.obj") .eqs. ""
$ then
$   cc/nested=none/include=[.lib]/object=sys$disk:[]vms_expand_args.obj -
        [.vms]vms_expand_args.c
$ endif
$!
$!
$! Set ACL to override protection, as makefile is removing write
$! access from files it then tries to rename or delete.
$ acl_perms = "access=read+write+execute+delete"
$ set security/acl=(identifier='f$user()','acl_perms') -
    sys$disk:[-]'my_dir_name'.dir
$ set security/acl=(identifier='f$user()',options=default,'acl_perms') -
   sys$disk:[-]'my_dir_name'.dir
$!
$! Needed for make check
$ sys_disk = f$trnlnm("sys$disk") - ":"
$ max_index = f$trnlnm(sys_disk,,,,, "max_index")
$ if max_index .ne. 0
$ then
$   base_disk = f$trnlnm(sys_disk,, 0)
$!   set directory/version_limit=1 'base_disk'[.tests]
$ else
$!   set directory/version_limit=1 sys$disk:[.tests]
$ endif
$!
$! Setup header files
$!-----------------------
$! For the configure step.
$ src_file = "gnv_conftest.c_first"
$ dst_file = "sys$disk:[]gnv$conftest.c_first"
$ if f$search(dst_file) .eqs. ""
$ then
$   copy/log [.vms]'src_file' 'dst_file'
$ endif
$ src_file = "gnv_conftest.opt"
$ dst_file = "sys$disk:[]gnv$conftest.opt"
$ if f$search(dst_file) .eqs. ""
$ then
$   if f$search("[.vms]''src_file'") .nes. ""
$   then
$	copy/log [.vms]'src_file' 'dst_file'
$   endif
$ endif
$!
$ src_file = "gnv_gzip.opt"
$ dst_file = "sys$disk:[]gnv$gzip.opt"
$ if f$search(dst_file) .eqs. ""
$ then
$   if f$search("[.vms]''src_file'") .nes. ""
$   then
$	copy/log [.vms]'src_file' 'dst_file'
$   endif
$ endif
$!
$!
$ src_file = "gnv_first_include.h"
$ dst_file = "sys$disk:[.lib]gnv$first_include.h"
$ if f$search(dst_file) .eqs. ""
$ then
$   copy/log [.vms]'src_file' 'dst_file'
$ endif
$ dst_file = "sys$disk:[]gnv$first_include.h"
$ if f$search(dst_file) .eqs. ""
$ then
$   copy/log [.vms]'src_file' 'dst_file'
$ endif
$!
$ src_file = "vms_stdio_ext.h"
$ dst_file = "sys$disk:[.lib]stdio_ext.h"
$ if f$search(dst_file) .eqs. ""
$ then
$   copy/log [.vms]'src_file' 'dst_file'
$ endif
$!
$ src_file = "gnv_program.opt"
$ dst_file = "sys$disk:[]gnv$cmp.opt"
$ if f$search(dst_file) .eqs. ""
$ then
$!   copy/log [.vms]'src_file' 'dst_file'
$ endif
$ dst_file = "sys$disk:[]gnv$diff.opt"
$ if f$search(dst_file) .eqs. ""
$ then
$!   copy/log [.vms]'src_file' 'dst_file'
$ endif
$ dst_file = "sys$disk:[]gnv$diff3.opt"
$ if f$search(dst_file) .eqs. ""
$ then
$!   copy/log [.vms]'src_file' 'dst_file'
$ endif
$ dst_file = "sys$disk:[]gnv$sdiff.opt"
$ if f$search(dst_file) .eqs. ""
$ then
$!   copy/log [.vms]'src_file' 'dst_file'
$ endif
$!
$! Here we really need a search list to fix up the source code.
$!
$ dst_file = "sys$disk:[.lib]float_plus.h"
$ if f$search(dst_file) .eqs. ""
$ then
$   copy/log [.lib]float^+.h 'dst_file'
$ endif
$!
$ eve_silent := edit/tpu/section=eve$section/nodisplay
$ unix_to_vms = "/comm=sys$disk:[.vms]unix_c_to_vms_c.tpu"
$!
$ define/user sys$output NLA0:
$ define/user sys$output NLA0:
$ search []tailor.h "VMSOLD"
$ severity = '$SEVERITY'
$ if severity .ne. 1
$ then
$   'eve_silent' 'unix_to_vms' sys$disk:[]tailor.h -
      /out=sys$disk:[]tailor.h/init=sys$disk:[.vms]tailor_h.tpu
$ endif
$!
$ define/user sys$output NLA0:
$ define/user sys$output NLA0:
$ search [.lib]isnan.c "__VMS"
$ severity = '$SEVERITY'
$ if severity .ne. 1
$ then
$   'eve_silent' 'unix_to_vms' sys$disk:[.lib]isnan.c -
      /out=sys$disk:[.lib]isnan.c/init=sys$disk:[.vms]lib_isnan_c.tpu
$ endif
$!
$ define/user sys$output NLA0:
$ define/user sys$output NLA0:
$ search [.lib]signbitd.c "__VMS"
$ severity = '$SEVERITY'
$ if severity .ne. 1
$ then
$   'eve_silent' 'unix_to_vms' sys$disk:[.lib]signbitd.c -
      /out=sys$disk:[.lib]signbitd.c/init=sys$disk:[.vms]lib_isnan_c.tpu
$ endif
$!
$ define/user sys$output NLA0:
$ define/user sys$output NLA0:
$ search [.lib]signbitf.c "__VMS"
$ severity = '$SEVERITY'
$ if severity .ne. 1
$ then
$   'eve_silent' 'unix_to_vms' sys$disk:[.lib]signbitf.c -
      /out=sys$disk:[.lib]signbitf.c/init=sys$disk:[.vms]lib_isnan_c.tpu
$ endif
$!
$ define/user sys$output NLA0:
$ define/user sys$output NLA0:
$ search [.lib]signbitl.c "__VMS"
$ severity = '$SEVERITY'
$ if severity .ne. 1
$ then
$   'eve_silent' 'unix_to_vms' sys$disk:[.lib]signbitl.c -
      /out=sys$disk:[.lib]signbitl.c/init=sys$disk:[.vms]lib_isnan_c.tpu
$ endif
$!
$ define/user sys$output NLA0:
$ define/user sys$output NLA0:
$ search [.lib]vasnprintf.c "__VMS"
$ severity = '$SEVERITY'
$ if severity .ne. 1
$ then
$   'eve_silent' 'unix_to_vms' sys$disk:[.lib]vasnprintf.c -
      /out=sys$disk:[.lib]vasnprintf.c/init=sys$disk:[.vms]lib_isnan_c.tpu
$ endif
$!
$!
$! Need to build a script to run configure
$!
$ vms_cfg_script = "sys$disk:[]vms_configure.sh"
$if f$search(vms_cfg_script) .eqs. ""
$then
$   config_hack1 = "sys$disk:[]config_hack1.out"
$   search/out='config_hack1' -
	configure "checking absolute name of <", ">&6;"/match=and
$!
$   create 'vms_cfg_script'
$   open/append cfg_out 'vms_cfg_script'
$   write cfg_out "#!/bin/bash"
$   write cfg_out "#"
$   write cfg_out "# Generated by vms/vms_prebuild.com"
$   write cfg_out "#"
$   write cfg_out "# Run the configure script with options needed for VMS"
$   write cfg_out "#"
$   write cfg_out "export gl_cv_func_working_mkstemp=yes"
$   write cfg_out "export gl_cv_func_getcwd_path_max=no"
$   write cfg_out "export gl_cv_func_working_utimes=yes"
$   write cfg_out "export gl_cv_func_fflush_stdin=yes"
$!
$! The assumption here is that there may local files with the same
$! name as system header files.  For VMS, configure tests fail for these
$! headers.  We add a hopefully fake path, which causes VMS to pull the
$! header from the text library after junking the path.
$   open/read cfg_hack1 'config_hack1'
$hack1_loop:
$	read cfg_hack1/end=hack1_loop_end line_in
$	if line_in .eqs. "" then goto hack1_loop
$	header_part = f$element(1, "<", line_in)
$	if header_part .eqs. "<" then goto hack1_loop
$	header = f$element(0, ">", header_part)
$	if header .eqs. "<" then goto hack1_loop
$	header = header - ".h"
$	pre_dir = f$element(0, "/", header)
$	if pre_dir .nes. header
$	then
$	    header = f$element(1, "/", header)
$	    header1 = pre_dir + "_" + header + "_h"
$	else
$	    header1 = header + "_h"
$	endif
$	header2 = header + ".h"
$	write cfg_out -
	   "export gl_cv_next_''header1'=""<vms_fake_path/''header2'>"""
$	goto hack1_loop
$hack1_loop_end:
$   close cfg_hack1
$!
$!  VMS provided replacement routines
$!   write cfg_out "export gl_cv_func___fpurge=yes"
$!   write cfg_out "export gl_cv_func___freadahead=yes"
$!   write cfg_out "export gl_cv_func___freading=yes"
$!   write cfg_out "export gl_cv_func___fseterr=yes"
$!
$   write cfg_out -
  "./configure --prefix=/usr --config-cache  --disable-dependency-tracking"
$   close cfg_out
$!
$   purge/log 'vms_cfg_script'
$endif
$!
$ arch_type = f$getsyi("ARCH_NAME")
$ node_swvers = f$getsyi("node_swvers")
$ vernum = f$extract(1, f$length(node_swvers), node_swvers)
$ majver = f$element(0, ".", vernum)
$ minverdash = f$element(1, ".", vernum)
$ minver = f$element(0, "-", minverdash)
$ dashver = f$element(1, "-", minverdash)
$ if dashver .eqs. "-" then dashver = ""
$ vmstag = arch_type + "_" + majver + "_" + minver
$ if dashver .nes. "" then vmstag = vmstag + "_" + dashver
$ vmstag = f$edit(vmstag, "lowercase")
$!
$!
$! Autoconf says not to provide a cached config file for a platform.
$! We do this here because configure takes too long to run and
$! will produce the same results for a VMS version.
$ vms_cache = "sys$disk:[.vms]config.cache_''vmstag'"
$ write sys$output "looking for ''vms_cache' file."
$ if f$search(vms_cache) .nes. ""
$ then
$   if f$search("sys$disk:[]config.cache") .eqs. ""
$   then
$       copy/log 'vms_cache' sys$disk:[]config.cache
$   endif
$ endif
$!
$!
$! The CRTL can not handle if the default is set to a directory that
$! does not exist in the first member of a search list.
$!
$! For simplicity, assume sys$disk is not a search list by itself
$! ---------------------------------------------------------------
$!
$! Becaues of recursive make, we need to copy some files to the
$! beginning of the search list to make sure the date order is
$! correct or make will attempt to rebuild them with tools that
$! are not currently present on VMS.
$!
$ sys_disk  = f$trnlnm("sys$disk") - ":"
$!
$ max_index = f$trnlnm(sys_disk,,,,, "max_index")
$ if max_index .ne. 0
$ then
$   base_disk = f$trnlnm(sys_disk,, 0)
$   i = 1
$   if f$search("'base_disk'[]configure.ac") .eqs. ""
$   then
$copy_loop:
$	if i .gt. max_index then goto copy_loop_end
$	diskn = f$trnlnm(sys_disk,, i)
$!
$!	Need all the m4 files for recursive make to work
$!
$	if f$search("''diskn'[.m4...]*.*") .nes. ""
$	then
$!	    copy 'diskn'[.m4...]*.* 'base_disk'[.m4...]
$!	    purge 'base_disk'[.m4...]
$	endif
$!
$!	configure.ac needs to be older than aclocal.m4 files.
$	if f$search("''diskn'[]configure.ac") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[]configure.ac 'base_disk'[]
$	    purge 'base_disk'[]configure.ac
$	endif
$!
$	if f$search("''diskn'[]aclocal.m4") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[]aclocal.m4 'base_disk'[]
$	    purge 'base_disk'[]aclocal.m4
$	endif
$!
$	if f$search("''diskn'[.lib]config.hin") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.lib]config.hin 'base_disk'[.lib]
$	    purge 'base_disk'[.lib]config.hin
$	endif
$!
$	if f$search("''diskn'[.doc]gzip.info") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.doc]gzip.info 'base_disk'[.doc]
$	    purge 'base_disk'[.doc]gzip.info
$	endif
$!
$	if f$search("''diskn'[]makefile.am") .nes. ""
$	then
$!	    wait 00:00:01
$	    copy 'diskn'[]makefile.am 'base_disk'[]
$	    purge 'base_disk'[]makefile.am
$	endif
$!
$	if f$search("''diskn'[.lib]makefile.am") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.lib]makefile.am 'base_disk'[.lib]
$	    purge 'base_disk'[.lib]makefile.am
$	endif
$!
$	if f$search("''diskn'[.doc]makefile.am") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.doc]makefile.am 'base_disk'[.doc]
$	    purge 'base_disk'[.doc]makefile.am
$	endif
$!
$	if f$search("''diskn'[.tests]makefile.am") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.tests]makefile.am 'base_disk'[.tests]
$	    purge 'base_disk'[.tests]makefile.am
$	endif
$!
$	if f$search("''diskn'[]makefile.in") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[]makefile.in 'base_disk'[]
$	    purge 'base_disk'[]makefile.in
$	endif
$!
$	if f$search("''diskn'[.lib]makefile.in") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.lib]makefile.in 'base_disk'[.lib]
$	    purge 'base_disk'[.lib]makefile.in
$	endif
$!
$	if f$search("''diskn'[.doc]makefile.in") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.doc]makefile.in 'base_disk'[.doc]
$	    purge 'base_disk'[.doc]makefile.in
$	endif
$!
$	if f$search("''diskn'[.tests]makefile.in") .nes. ""
$	then
$	    wait 00:00:01
$	    copy 'diskn'[.tests]makefile.in 'base_disk'[.tests]
$	    purge 'base_disk'[.tests]makefile.in
$	endif
$!
$!	configure must be newer than m4 files
$!
$	if f$search("''diskn'[]configure.") .nes. ""
$	then
$	    wait 00:00:02
$	    copy 'diskn'[]configure. 'base_disk'[]
$	    purge 'base_disk'[]configure.
$	endif
$!
$	if f$search("''diskn'[.tests]basic.") .nes. ""
$	then
$!	    wait 00:00:01
$!	    copy 'diskn'[.tests]*.*/exc=(makefile.*,*.dir) 'base_disk'[.tests]
$!	    purge 'base_disk'[.tests]
$	endif
$!
$!
$	i = i + 1
$	goto copy_loop
$copy_loop_end:
$   endif
$ endif
$skip_copy_loop:
$!
