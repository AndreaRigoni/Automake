#! /bin/sh
# Copyright (C) 2002-2017 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Try to build and package a program linked to a Libtool library.
# Also make sure we do not bloat the Makefile with unneeded rules.

required='cc libtoolize'
. test-init.sh

cat >> configure.ac << 'END'
AC_PROG_CC
AM_PROG_AR
AM_PROG_LIBTOOL
AC_OUTPUT
END

cat > Makefile.am << 'END'
lib_LTLIBRARIES = lib0.la liba/liba.la
lib0_la_SOURCES = 0.c
liba_liba_la_SOURCES = liba/a.c

bin_PROGRAMS = 1
1_SOURCES = sub/1.c
1_LDADD = lib0.la liba/liba.la
END

mkdir liba sub

cat > 0.c << 'END'
int
zero (void)
{
   return 0;
}
END

cat > sub/1.c << 'END'
int zero ();

int
main (void)
{
   return zero ();
}
END

cat > liba/a.c << 'END'
int
a (void)
{
   return 'a';
}
END

# Use --copy to workaround a bug in Cygwin's 'cp -p' during distcheck.
# (This bug is already exhibited by subobj9.sh.)  In brief: Cygwin's
# 'cp -p' tries to preserve group and owner of the source and fails
# to do so under normal accounts.  With --copy we ensure we own all files.

libtoolize --force --copy
$ACLOCAL
$AUTOCONF
$AUTOMAKE --add-missing --copy

# We shouldn't need explicit rules.
grep -v '^\.c' Makefile.in \
  | $FGREP -v '$(am__dirstamp)' \
  | $EGREP '\.(o|obj|lo).*:' && exit 1

./configure

$MAKE
$MAKE distcheck

:
