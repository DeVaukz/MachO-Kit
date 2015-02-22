Mach-O Kit
==========

Mach-O Kit is a C/Objective-C framework for parsing Mach-O binaries used by OS X and iOS.  The project includes two libraries: libMachO and MachOKit.

## Status

Mach-O Kit is not yet complete.  Currently the libraries can parse these parts of executable, dynamic shared library, and bundle binaries:

- FAT Header (MachOKit only)
- Mach Header
- All Load Commands except
    * LC_SYMSEG
    * LC_THREAD
    * LC_UNIXTHREAD
    * LC_LOADFVMLIB
    * LC_IDFVMLIB
    * LC_IDENT
    * LC_FVMFILE
    * LC_PREPAGE
    * LC_PREBOUND_DYLIB
    * LC_SUB_UMBRELLA
    * LC_LAZY_LOAD_DYLIB
    * LC_LINKER_OPTION
    * LC_LINKER_OPTIMIZATION_HINT
- Segments and Sections
    * Not all types of sections are fully parsed
- Link Edit string table
- Link Edit symbol table
    * Not all types of symbols are fully parsed
- Indirect symbol table

## libMachO

libMachO is a lightweight, C library for parsing in-memory Mach-O images.  It should not be used to parse binaries which have **not** been loaded into memory by the kernel/dyld.  To keep the library lightweight libMachO overlays itself atop the MachO binary and provides a structured set of APIs to parse the data. libMachO does not build up its own independent representation of the Mach-O opting to continuously walk the Mach-O structures to access requested data.  This means that libMachO generally expects well-formed MachO binaries.

Differences between the target architecture of the Mach-O binary and your process are handled by libMachO.  Access to data of the Mach-O image is abstracted by a memory map and one or more memory objects vended by the map.  libMachO includes memory maps for accessing MachO images loaded into the current process, or another process for which your process has rights to the task port.  Memory access through a memory map is checked to ensure invalid memory cannot be accidentally accessed, in the case of a malformed Mach-O binary.

libMachO does not perform any dynamic memory allocation.  Clients are responsible for allocating buffers which are then initialized by the various parsers in libMachO.  Consequently, the lifetimes of these buffers must be managed by clients.

## MachOKit

MachOKit is an Objective-C library for parsing Mach-O binaries.  It's built atop the core of libMachO but (currently) contains a different collection of parsers.  MachOKit parses each part of a Mach-O binary once and builds up a graph of objects, derived from MKNode, each representing part of the Mach-O data.

Like libMachO, differences between the target architecture of the Mach-O binary and your process are handled by an <MKDataModel> object created by the MKMachOImage parsing a Mach-O binary.  Access to the data of a Mach-O binary is mediated by an instance of MKMemoryMap, which verifies that each memory access is to a valid range and maps the referenced part of the binary into your process.  Subclasses of MKMemoryMap are provided to read binaries on disk, in the current process, and in other processes for which your process has rights to the task port.

## License

Mach-O Kit is released under the MIT license. See
[LICENSE.md](https://github.com/DeVaukz/MachO-Kit/blob/master/LICENSE).