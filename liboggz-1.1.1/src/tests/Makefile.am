## Process this file with automake to produce Makefile.in

INCLUDES = -I$(top_builddir) -I$(top_builddir)/include \
           -I$(top_srcdir)/include \
           @OGG_CFLAGS@

OGGZDIR = ../liboggz
OGGZ_LIBS = $(OGGZDIR)/liboggz.la @OGG_LIBS@

# Test programs

TESTS_ENVIRONMENT = $(VALGRIND_ENVIRONMENT)

test: check

comment_tests = comment-test

if OGGZ_CONFIG_WRITE
write_tests = write-bad-guard write-unmarked-guard write-recursive \
	write-bad-bytes write-bad-bos write-dup-bos write-bad-eos \
	write-bad-granulepos write-bad-packetno write-bad-serialno \
	write-prefix write-suffix
endif

if OGGZ_CONFIG_READ
if OGGZ_CONFIG_WRITE
rw_tests = read-generated read-stop-ok read-stop-err \
	io-read io-seek io-write io-read-single io-write-flush io-run io-count
endif
endif

if OGGZ_CONFIG_READ
seek_progs = seek-stress
seek_tests = seek-stress-test.sh
endif

noinst_SCRIPTS = $(seek_tests)
noinst_PROGRAMS = $(comment_tests) $(write_tests) $(rw_tests) $(seek_progs)
noinst_HEADERS = oggz_tests.h comment-test.h

EXTRA_DIST = $(seek_tests)

#TESTS = $(write_tests) $(rw_tests) $(seek_tests)
TESTS = $(comment_tests) $(write_tests) $(rw_tests)

comment_test_SOURCES = comment-test.c
comment_test_LDADD = $(OGGZ_LIBS)

write_bad_guard_SOURCES = write-bad-guard.c
write_bad_guard_LDADD = $(OGGZ_LIBS)

write_unmarked_guard_SOURCES = write-unmarked-guard.c
write_unmarked_guard_LDADD = $(OGGZ_LIBS)

write_recursive_SOURCES = write-recursive.c
write_recursive_LDADD = $(OGGZ_LIBS)

write_bad_bytes_SOURCES = write-bad-bytes.c
write_bad_bytes_LDADD = $(OGGZ_LIBS)

write_bad_bos_SOURCES = write-bad-bos.c
write_bad_bos_LDADD = $(OGGZ_LIBS)

write_dup_bos_SOURCES = write-dup-bos.c
write_dup_bos_LDADD = $(OGGZ_LIBS)

write_bad_eos_SOURCES = write-bad-eos.c
write_bad_eos_LDADD = $(OGGZ_LIBS)

write_bad_granulepos_SOURCES = write-bad-granulepos.c
write_bad_granulepos_LDADD = $(OGGZ_LIBS)

write_bad_packetno_SOURCES = write-bad-packetno.c
write_bad_packetno_LDADD = $(OGGZ_LIBS)

write_bad_serialno_SOURCES = write-bad-serialno.c
write_bad_serialno_LDADD = $(OGGZ_LIBS)

write_prefix_SOURCES = write-prefix.c
write_prefix_LDADD = $(OGGZ_LIBS)
write_suffix_SOURCES = write-suffix.c
write_suffix_LDADD = $(OGGZ_LIBS)

read_generated_SOURCES = read-generated.c
read_generated_LDADD = $(OGGZ_LIBS)

read_stop_ok_SOURCES = read-stop-ok.c
read_stop_ok_LDADD = $(OGGZ_LIBS)

read_stop_err_SOURCES = read-stop-err.c
read_stop_err_LDADD = $(OGGZ_LIBS)

io_count_SOURCES = io-count.c
io_count_LDADD = $(OGGZ_LIBS)

io_read_SOURCES = io-read.c
io_read_LDADD = $(OGGZ_LIBS)

io_run_SOURCES = io-run.c
io_run_LDADD = $(OGGZ_LIBS)

io_seek_SOURCES = io-seek.c
io_seek_LDADD = $(OGGZ_LIBS)

io_write_SOURCES = io-write.c
io_write_LDADD = $(OGGZ_LIBS)

io_read_single_SOURCES = io-read-single.c
io_read_single_LDADD = $(OGGZ_LIBS)

io_write_flush_SOURCES = io-write-flush.c
io_write_flush_LDADD = $(OGGZ_LIBS)

seek_stress_SOURCES = seek-stress.c
seek_stress_LDADD = $(OGGZ_LIBS)
