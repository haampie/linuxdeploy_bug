# Running the example

```
$ git clone git@github.com:haampie/linuxdeploy_bug.git
$ cd linuxdeploy_bug
$ ./run.sh
```

## What it's doing

It builds 1 executable (`Example.AppDir/usr/bin/example`) and 2 shared libraries (`deps/libdep1.so`, `deps/libdep2.so`).

The dependencies are: `example <- libdep2.so <- libdep1.so`.

All binaries have RUNPATH set up:

- The RUNPATH of `example` is the the absolute path to the `deps/` folder.
- The RUNPATH of `libdep2.so` is $ORIGIN, so it will find `libdep1.so` in its own folder.

## The issue

When running `linuxdeployqt`, the `deps/libdep2.so` library is moved to `Example.AppDir/usr/lib`, and `ldd` is run on this library again. At this point `libdep1.so` cannot be found, because (1) `RUNPATH` is not inherited and (2) `$ORIGIN` is the directory of the library itself, which has changed to the lib folder in the AppDir.

## Example output

```
$ ./run.sh
...
ERROR: ldd outputLine: "libdep1.so => not found"
ERROR: for binary: "/home/user/projects/linuxdeploy_bug/Example.AppDir/usr/lib///libdep2.so"
ERROR: Please ensure that all libraries can be found by ldd. Aborting.
```

## ldd / readelf of executable / libs

```
$ readelf -d deps/libdep2.so | grep path
 0x000000000000001d (RUNPATH)            Library runpath: [$ORIGIN]

$ readelf -d Example.AppDir/usr/bin/example | grep path
 0x000000000000001d (RUNPATH)            Library runpath: [/home/user/projects/linuxdeploy_bug/deps]

$ ldd -d Example.AppDir/usr/bin/example
	linux-vdso.so.1 (0x00007ffdcfadd000)
	libdep2.so => /home/user/projects/linuxdeploy_bug/deps/libdep2.so (0x00007f022a7ee000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f022a465000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f022a074000)
	libdep1.so => /home/user/projects/linuxdeploy_bug/deps/libdep1.so (0x00007f0229e72000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f0229ad4000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f022abf2000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f02298bc000)
```
