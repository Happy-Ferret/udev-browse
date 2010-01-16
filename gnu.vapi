/***
  This file is part of udev-browse.

  Copyright 2009 Lennart Poettering

  dbus-browse is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation; either version 2.1 of the
  License, or (at your option) any later version.

  dbus-browse is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with dbus-browse; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***/

[CCode(cheader_filename="stdlib.h")]
namespace Gnu {
        [CCode (cname = "canonicalize_file_name")]
        public string? canonicalize_file_name(string path);
}
