# This file is part of udev-browse.
#
# Copyright 2009 Lennart Poettering
#
# udev-browse is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# udev-browse is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with udev-browse; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA.

udev-browse: udev-browse.vala
	valac --save-temps --pkg gee-1.0 --pkg gtk+-3.0 --pkg gudev-1.0 --pkg gnu --vapidir=. --Xcc=-D_GNU_SOURCE udev-browse.vala

clean:
	rm -f udev-browse udev-browse.c

release:
	test "x$$VERSION" != x
	git tag v$$VERSION -m "udev-browse $$VERSION"
	git archive --prefix=udev-browse-$$VERSION/ v$$VERSION | xz -c > udev-browse-$$VERSION.tar.xz
	scp udev-browse-$$VERSION.tar.xz tango:public/
