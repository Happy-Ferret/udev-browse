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
