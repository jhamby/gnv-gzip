$! File: clean_gzip.com
$!
$! Procedure to clean gzip build products on VMS.
$!
$! Copyright 2017, John Malmberg
$!
$! Permission to use, copy, modify, and/or distribute this software for any
$! purpose with or without fee is hereby granted, provided that the above
$! copyright notice and this permission notice appear in all copies.
$!
$! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
$! WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
$! MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
$! ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
$! WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
$! ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
$! OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
$!
$!
$!
$!=========================================================================
$!
$ p1_up = f$edit(p1, "UPCASE")
$!
$ file = "[...]*.o"
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "*.obj"
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "[...]*.lis"
$ if f$search(file) .nes. "" then delete 'file';*
$!
$ file = "[.CXX_REPOSITORY]CXX$DEMANGLER_DB."
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "CXX_REPOSITORY.DIR"
$ if f$search(file) .nes. "" then set file/prot=(o:rwed) 'file';*
$ if f$search(file) .nes. "" then delete 'file';*
$!
$ file = "[.LIB.CXX_REPOSITORY]CXX$DEMANGLER_DB."
$ if f$search(file) .nes. "" then delete 'file';*
$ file = "[.LIB]CXX_REPOSITORY.dir"
$ if f$search(file) .nes. "" then set file/prot=(o:rwed) 'file';*
$ if f$search(file) .nes. "" then delete 'file';*
$!
$!
$ if p1_up .eqs. "REALCLEAN"
$ then
$   file = "gzip."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gzexe."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zcat."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zcmp."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zdiff."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zegrep."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zfgrep."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zforce."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zgrep."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zless."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "zmore."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "znew."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gunzip."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gzip.exe"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "*.dsf"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gnv$gzip.opt"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "libver.a"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "version.c"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "version.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "vms_configure.sh"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]gnv$conftest.c_first"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]gnv$first_include.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]config.cache"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]config.log"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]config.status"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]dirstamp."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...].dirstamp"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[...]Makefile."
$   if f$search(file) .nes. "" then delete 'file';*
$!   file = "copying."
$!   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]alloca.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]arg-nonnull.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]c^+^+defs.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]charset.alias"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]config.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]configmake.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]dirent.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]errno.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]fcntl.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]float_plus.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]getopt.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]math.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]stddef.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]stdint.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]stdio.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]stdio_ext.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]stdlib.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]string.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]time.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]unistd.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]unused-parameter.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]warn-on-use.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]wchar.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]wctype.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib.sys]stat.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib.sys]time.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib.sys]types.h"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]stamp-h1."
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]ref-add.sed"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]ref-del.sed"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "[.lib]libgzip.a"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "*.pcsi$desc"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "*.pcsi$text"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "*.release_notes"
$   if f$search(file) .nes. "" then delete 'file';*
$   file = "gzip-*.bck"
$   if f$search(file) .nes. "" then delete 'file';*
$ endif

