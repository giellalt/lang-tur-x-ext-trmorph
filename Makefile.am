## Process this file with automake to produce Makefile.in
## Copyright: Sámediggi/Divvun/UiT
## Licence: GPL v3+

ACLOCAL_AMFLAGS = -I m4
SUBDIRS = . src tools docs

update:
	git subtree pull --prefix src/fst/morphology/ext-TRmorph https://github.com/coltekin/TRmorph.git master --squash

include $(top_srcdir)/../giella-core/am-shared/topdir-include.am
include $(top_srcdir)/../giella-core/am-shared/devtest-include.am
