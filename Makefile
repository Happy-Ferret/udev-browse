udev-browse: udev-browse.vala gudev-1.0.vapi
	valac --pkg gee-1.0 --pkg gtk+-2.0 --pkg gudev-1.0 --pkg gnu --vapidir=. --Xcc=-D_GNU_SOURCE udev-browse.vala

clean:
	rm -f udev-browse
