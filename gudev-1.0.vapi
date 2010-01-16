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

[CCode(cprefix="GUdev", lower_case_cprefix="g_udev_", cheader_filename="gudev/gudev.h")]
namespace Udev {

        public class Device : GLib.Object {
                public unowned string get_name();
                public unowned string get_subsystem();
                public unowned string get_sysfs_path();
                public unowned string? get_devtype();
                public unowned string? get_driver();
                public unowned string? get_device_file();
                public unowned string? get_number();
                public unowned Device? get_parent();

                public unowned string? get_property(string key);

                [CCode (array_length = false, array_null_terminated = true)]
                public unowned string[] get_property_keys();

                [CCode (array_length = false, array_null_terminated = true)]
                public unowned string[] get_device_file_symlinks();

                public uint64 get_seqnum();
        }

        public class Client : GLib.Object {

                public Client([CCode (array_length = false)] string[]? subsystems = null);

                public GLib.List<Device> query_by_subsystem(string? subsystem = null);
                public Device query_by_sysfs_path(string sysfs_path);

                public signal void uevent(string action, Device d);
        }
}
