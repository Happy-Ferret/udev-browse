# This file is part of dbus-browse.
#
# Copyright 2009 Lennart Poettering
#
# dbus-browse is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# dbus-browse is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with dbus-browse; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA.

udev-browse: udev-browse.vala gudev-1.0.vapi
	valac --pkg gee-1.0 --pkg gtk+-2.0 --pkg gudev-1.0 --pkg gnu --vapidir=. --Xcc=-D_GNU_SOURCE --Xcc=-DG_UDEV_API_IS_SUBJECT_TO_CHANGE udev-browse.vala

clean:
	rm -f udev-browse
