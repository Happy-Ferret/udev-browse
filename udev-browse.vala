/***
  This file is part of udev-browse.

  Copyright 2009 Lennart Poettering

  udev-browse is free software; you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation; either version 2.1 of the
  License, or (at your option) any later version.

  udev-browse is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with udev-browse; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA.
***/

using GUdev;
using Gtk;
using GLib;
using Pango;
using Gee;
using Gnu;

public class LeftLabel : Label {
        public LeftLabel(string? text = null) {
                if (text != null)
                        set_markup("<b>%s</b>".printf(text));
                this.xalign = 1;
                this.margin_end = 6;
        }
}

public class RightLabel : Label {
        public RightLabel(string? text = null) {
                set_text_or_na(text);
                this.xalign = 0;
                set_ellipsize(EllipsizeMode.START);
                set_selectable(true);
        }

        public void set_text_or_na(string? text = null) {
                if (text == null)
                        set_markup("<i>n/a</i>");
                else
                        set_text(text);
        }
}

public class MainWindow : Window {
        private GUdev.Client client;

        private TreeView device_view;
        private TreeView property_view;

        private TreeStore device_model;
        private Gtk.ListStore property_model;

        private RightLabel name_label;
        private RightLabel subsystem_label;
        private RightLabel sysfs_path_label;
        private RightLabel parent_sysfs_path_label;
        private RightLabel devtype_label;
        private RightLabel driver_label;
        private RightLabel device_file_label;
        private RightLabel device_file_symlinks_label;
        private RightLabel number_label;
        private RightLabel seqnum_label;

        private LinkButton parent_button;

        private CheckButton follow_add_check_button;
        private CheckButton follow_change_check_button;

        private HashMap<string,TreeRowReference> rows;
        private HashMap<string,uint64?> seqnums;

        public MainWindow() {

                title = "udev-browse";
                set_position(WindowPosition.CENTER);
                set_default_size(1000, 700);
                set_border_width(12);

                destroy.connect(Gtk.main_quit);

                rows = new HashMap<string, TreeRowReference>();
                seqnums = new HashMap<string, uint64?>();

                client = new GUdev.Client(null);

                client.uevent.connect(uevent);

                device_model = new TreeStore(3, typeof(string), typeof(string), typeof(string));
                property_model = new Gtk.ListStore(2, typeof(string), typeof(string));

                device_view = new TreeView.with_model(device_model);
                property_view = new TreeView.with_model(property_model);

                device_view.cursor_changed.connect(device_changed);
                device_view.set_enable_tree_lines(true);

                device_view.insert_column_with_attributes(-1, "Device", new CellRendererText(), "text", 0);
                device_view.insert_column_with_attributes(-1, "Subsystem", new CellRendererText(), "text", 2);
                property_view.insert_column_with_attributes(-1, "Property", new CellRendererText(), "text", 0);
                property_view.insert_column_with_attributes(-1, "Value", new CellRendererText(), "text", 1);

                Paned hpaned = new Paned(Orientation.HORIZONTAL);
                add(hpaned);

                ScrolledWindow scroll = new ScrolledWindow(null, null);
                scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
                scroll.set_shadow_type(ShadowType.IN);
                scroll.add(device_view);
                hpaned.pack1(scroll, true, false);

                Box vbox = new Box(Orientation.VERTICAL, 6);
                hpaned.pack2(vbox, true, false);

                Gtk.Grid layout = new Gtk.Grid();
                layout.row_spacing = 6;
                vbox.pack_start(layout, false, false, 0);

                name_label = new RightLabel();
                subsystem_label = new RightLabel();
                sysfs_path_label = new RightLabel();
                parent_sysfs_path_label = new RightLabel();
                devtype_label = new RightLabel();
                driver_label = new RightLabel();
                device_file_label = new RightLabel();
                device_file_symlinks_label = new RightLabel();
                number_label = new RightLabel();
                seqnum_label = new RightLabel();

                layout.attach(new LeftLabel("Name:"), 0, 1, 1, 1);
                layout.attach(new LeftLabel("Subsystem:"), 0, 2, 1, 1);
                layout.attach(new LeftLabel("Sysfs Path:"), 0, 3, 1, 1);
                layout.attach(new LeftLabel("Parent Sysfs Path:"), 0, 4, 1, 1);
                layout.attach(new LeftLabel("Device Type:"), 0, 5, 1, 1);
                layout.attach(new LeftLabel("Driver:"), 0, 6, 1, 1);
                layout.attach(new LeftLabel("Device File:"), 0, 7, 1, 1);
                layout.attach(new LeftLabel("Device File Symbolic Link(s):"), 0, 8, 1, 1);
                layout.attach(new LeftLabel("Number:"), 0, 9, 1, 1);
                layout.attach(new LeftLabel("Sequence Number:"), 0, 10, 1, 1);

                layout.attach(name_label, 1, 1, 1, 1);
                layout.attach(subsystem_label, 1, 2, 1, 1);
                layout.attach(sysfs_path_label, 1, 3, 1, 1);
                layout.attach(parent_sysfs_path_label, 1, 4, 1, 1);
                layout.attach(devtype_label, 1, 5, 1, 1);
                layout.attach(driver_label, 1, 6, 1, 1);
                layout.attach(device_file_label, 1, 7, 1, 1);
                layout.attach(device_file_symlinks_label, 1, 8, 1, 1);
                layout.attach(number_label, 1, 9, 1, 1);
                layout.attach(seqnum_label, 1, 10, 1, 1);

                parent_button = new LinkButton("Go To Parent");
                layout.attach(parent_button, 0, 11, 1, 1);

                scroll = new ScrolledWindow(null, null);
                scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
                scroll.set_shadow_type(ShadowType.IN);
                scroll.add(property_view);
                vbox.pack_start(scroll, true, true, 0);

                follow_change_check_button = new CheckButton.with_mnemonic("Focus follows _changing devices");
                follow_add_check_button = new CheckButton.with_mnemonic("Focus follows _new devices");
                follow_add_check_button.set_active(true);
                vbox.pack_start(follow_add_check_button, false, false, 0);
                vbox.pack_start(follow_change_check_button, false, false, 0);

                parent_button.clicked.connect(go_to_parent);

                add_all_devices();
        }

        public void add_device(Device d) {
                string sysfs = d.get_sysfs_path();
                Device p = d.get_parent();
                TreeIter i;

                if (p == null)
                        device_model.append(out i, null);
                else {
                        string psysfs = p.get_sysfs_path();

                        if (rows.has_key(psysfs)) {
                                TreeIter pi;

                                device_model.get_iter(out pi, rows[psysfs].get_path());
                                device_model.append(out i, pi);
                        } else
                                device_model.append(out i, null);
                }

                device_model.set(i, 0, d.get_name(), 1, sysfs, 2, d.get_subsystem());
                rows[sysfs] = new TreeRowReference(device_model, device_model.get_path(i));

                uint64 sn = d.get_seqnum();
                if (sn != 0)
                        seqnums[sysfs] = sn;
        }

        public void remove_device(Device d) {
                string sysfs = d.get_sysfs_path();

                if (!rows.has_key(sysfs))
                        return;

                TreeIter i;
                device_model.get_iter(out i, rows[sysfs].get_path());
                device_model.remove(ref i);

                rows.unset(sysfs);
                seqnums.unset(sysfs);
        }

        public void add_all_devices() {
                foreach (Device d in client.query_by_subsystem(null))
                        add_device(d);

                device_view.expand_all();
        }

        public Device? get_current_device() {
                TreePath p;
                TreeIter iter;
                string sysfs;

                device_view.get_cursor(out p, null);

                if (p == null)
                        return null;

                device_model.get_iter(out iter, p);
                device_model.get(iter, 1, out sysfs);

                return client.query_by_sysfs_path(sysfs);
        }

        public void set_current_device(Device? d) {
                string sysfs = d.get_sysfs_path();

                if (rows.has_key(sysfs))
                        device_view.set_cursor(rows[sysfs].get_path(), null, false);
        }

        public Device lookup_sysfs(string sysfs) {
                Device d = client.query_by_sysfs_path(sysfs);

                if (d == null) {
                        string t = canonicalize_file_name(sysfs);

                        if (t != null)
                                d = client.query_by_sysfs_path(t);
                }

                return d;
        }

        public void set_current_device_by_sysfs_path(string? sysfs) {
                Device d;

                if (sysfs == null)
                        d = lookup_sysfs(Environment.get_current_dir());
                else {
                        d = lookup_sysfs(sysfs);

                        if (d == null)
                                d = lookup_sysfs(Path.build_filename(Environment.get_current_dir(), sysfs));

                        if (d == null)
                        d = lookup_sysfs(Path.build_filename("/sys/", sysfs));
                }

                if (d != null)
                        set_current_device(d);
        }

        public void device_changed() {
                Device d;

                d = get_current_device();

                if (d == null)
                        device_clear();
                else
                        device_update(d);
        }

        public void go_to_parent() {
                Device d = get_current_device();

                if (d != null) {
                        Device p = d.get_parent();

                        if (p != null)
                                set_current_device(p);
                }
        }

        public void device_clear() {
                name_label.set_text_or_na();
                subsystem_label.set_text_or_na();
                sysfs_path_label.set_text_or_na();
                parent_sysfs_path_label.set_text_or_na();
                devtype_label.set_text_or_na();
                driver_label.set_text_or_na();
                device_file_label.set_text_or_na();
                device_file_symlinks_label.set_text_or_na();
                number_label.set_text_or_na();
                seqnum_label.set_text_or_na();

                property_model.clear();

                parent_button.set_sensitive(false);
                parent_button.set_uri("n/a");
        }

        public void device_update(Device d) {

                string sysfs = d.get_sysfs_path();

                name_label.set_text_or_na(d.get_name());
                subsystem_label.set_text_or_na(d.get_subsystem());
                sysfs_path_label.set_text_or_na(sysfs);
                devtype_label.set_text_or_na(d.get_devtype());
                driver_label.set_text_or_na(d.get_driver());
                device_file_label.set_text_or_na(d.get_device_file());
                number_label.set_text_or_na(d.get_number());

                property_model.clear();
                foreach (var k in d.get_property_keys()) {
                        TreeIter iter;
                        property_model.append (out iter);
                        property_model.set(iter, 0, k);
                        var v = d.get_property(k);
                        property_model.set(iter, 1, v == null ? "n/a" : v);
                }

                Device p = d.get_parent();
                if (p == null) {
                        parent_button.set_sensitive(false);
                        parent_button.set_uri("n/a");
                        parent_sysfs_path_label.set_text_or_na();
                } else {
                        string psysfs = p.get_sysfs_path();

                        parent_button.set_sensitive(rows.has_key(psysfs));
                        parent_button.set_uri(psysfs);
                        parent_sysfs_path_label.set_text_or_na(psysfs);
                }

                if (seqnums.has_key(sysfs))
                        seqnum_label.set_text_or_na("%"+uint64.FORMAT_MODIFIER.printf(seqnums[sysfs]));
                else
                        seqnum_label.set_text_or_na();

                var l = d.get_device_file_symlinks();
                if (l != null && l.length > 0)
                        device_file_symlinks_label.set_text_or_na(string.joinv("\n", l));
                else
                        device_file_symlinks_label.set_text_or_na();

        }

        public void uevent(string action, Device d) {
                string sysfs = d.get_sysfs_path();

                if (action == "remove") {
                        remove_device(d);

                        Device current = get_current_device();
                        if (current == null || current.get_sysfs_path() == d.get_sysfs_path())
                                device_clear();

                } else if (action == "add") {
                        add_device(d);
                        device_view.expand_all();
                }

                if (rows.has_key(sysfs)) {
                        seqnums[sysfs] = d.get_seqnum();

                        if ((action == "change" && follow_change_check_button.get_active()) ||
                            (action == "add" && follow_add_check_button.get_active()))
                                set_current_device(d);

                        else if (action == "change") {
                                Device current = get_current_device();
                                if (current != null && current.get_sysfs_path() == d.get_sysfs_path())
                                        device_update(current);
                        }
                }
        }

        public void scroll_to_cursor() {
                TreePath p;

                device_view.get_cursor(out p, null);
                device_view.scroll_to_cell(p, null, true, 0.5f, 0);
        }
}

int main (string[] args) {
        Gtk.init(ref args);

        MainWindow window = new MainWindow();
        window.set_current_device_by_sysfs_path(args.length > 1 ? args[1] : null);
        window.show_all();
        window.scroll_to_cursor();

        Gtk.main ();
        return 0;
}
