<p align="center">
    <img width="850" height="200" src="https://raw.githubusercontent.com/DeVaukz/MachO-Kit/master/.github/banner.png">
</p>

## What is Mach-O Kit?

Mach-O Kit is an Objective-C framework for parsing Mach-O binaries used by Darwin platforms (macOS, iOS, tvOS, and watchOS).  The project also includes a lightweight C library - libMachO - for parsing Mach-O images loaded in the current process.

Mach-O Kit is designed to be easy to use while still exposing all the details of the parsed Mach-O file (if you need them).  It can serve as the foundation for anything that needs to read Mach-O files - from a one-off command line tool up to a fully featured interactive disassembler.  Most importantly, Mach-O Kit is designed to be safe.  Every read operation and its returned data is extensively error checked so that parsing a malformed Mach-O file (even a malicious one) does not crash your program.

## Projects Using Mach-O Kit

* [Mach-O Explorer](https://github.com/DeVaukz/MachO-Explorer) - A graphical Mach-O viewer for macOS.

## Getting Started

Mach-O Kit supports 32/64 bit OS X 10.10+, iOS 8.0+, and tvOS 9.0+.

*NOTE*: Mach-O Kit can build with older versions of Xcode.  However, the unit tests require the latest Xcode or command line tools to pass.

### Obtaining Mach-O Kit

***Use a recursive git clone***.

```
git clone --recursive https://github.com/DeVaukz/MachO-Kit
```

### Installation

1. Clone the Mach-O repository into your application's repository.
```
cd MyGreatApp;
git clone --recursive https://github.com/DeVaukz/MachO-Kit
```
2. Drag and drop MachOKit.xcodeproj into your application’s Xcode project or workspace.
3. On the “General” tab of your application target’s settings, add MachOKit.framework to the “Embedded Binaries” section.

### Using Mach-O Kit

Before Mach-O Kit can begin parsing a file, you must first create an `MKMemoryMap` for the file.  The memory map is used by the rest of Mach-O Kit to safely read the file's contents.  An `MKMemoryMap` can instead be instantiated with a task port for parsing a Mach-O image loaded in a process that you posses the task port for.

```
let memoryMap = try! MKMemoryMap(contentsOfFile: URL(fileURLWithPath: "/System/Library/Frameworks/Foundation.framework/Foundation"))
```

If the file is a FAT binary, Mach-O Kit provides the `MKFatBinary` class for parsing the FAT header.

```
let fatBinary = try! MKFatBinary(memoryMap: memoryMap)

# Retrieve the x86_64 slice
let slice64 = fatBinary.architectures.first { $0.cputype == CPU_TYPE_X86_64 }

# Retrieve the offset of the x86_64 slice within the file
let slice64FileOffset = slice64!.offset
```

You can now instantiate an instance of `MKMachOImage`.  This class is the top-level parser for a Mach-O binary.  `MKMachOImage` requires a memory map and an offset in the provided memory map to begin parsing.  For a FAT binary, this is the file offset of the slice you want to parse.  For in-process parsing, this is the load address of the Mach-O image which you can retrieve using the `dyld_*` APIs.

```
let macho = try! MKMachOImage(name: "Foundation", flags: .init(rawValue: 0), atAddress: mk_vm_address_t(slice64FileOffset), inMapping: memoryMap)
```

#### Retrieving Load Commands

Load commands can be retrieved from the `loadCommands` property of `MKMachOImage`.  Each load command is represented by a instance of an `MKLoadCommand` subclass.

```
let loadCommands = macho.loadCommands

print(loadCommands)
``` 

Most classes in Mach-O Kit print verbose debug descriptions.  `MKLoadCommand` is no exception.

```
# The above code outputs:
[
   ...
<MKLCLoadDylib 0x7fa647b36a30; contextAddress = 0x1f38; size = 104> {
	name.offset = 24
	timestamp = 1970-01-01 00:00:02 +0000
	current version = 1.0.0
	compatibility version = 1.0.0
	name = <MKLoadCommandString 0x7fa647b49080; contextAddress = 0x1f50; size = 80> {
		offset = 24
		string = /System/Library/Frameworks/DiskArbitration.framework/Versions/A/DiskArbitration
	}
},
   ...
]
```

#### Dependent Libraries

If you just want to inspect the libraries that a Mach-O binary links against, `MKLoadCommand` includes a `dependentLibraries` property that returns an array of `MKDependentLibrary` instances.  `MKDependentLibrary` provides a slightly higher level interface than inspecting the load commands directly.

```
# Prints the names of all the libraries that Foundation links against
for library in macho.dependentLibraries {
	print(library.value!.name)
}
```

#### Objective-C Metadata

Mach-O Kit has complete support for parsing Objective-C metadata.  Here is how to print the names of all Objective-C classes in a Mach-O binary:

```
for (_, section) in macho.sections {
	// Mach-O Kit instantiates specialized subclass of MKSection when it encounters a section containing Objective-C class list metadata
	guard let section = section as? MKObjCClassListSection else { continue }
	
	for clsPointer in section.elements {
		// The __objc_(n)classlist sections are just a list of pointers to class structures in the data section
		guard let cls = clsPointer.pointee.value else { continue}
		// The pointer to the class name is stored in the class data structure
		guard let clsData = cls.classData.pointee.value else { continue }
		// Finally, the name is a pointer to a string in the strings section
		guard let clsName = clsData.name.pointee.value else { continue }
		
		print(clsName)
	}
}
```


## Status

Mach-O Kit currently supports executables, dynamic shared libraries (dylibs and frameworks), and bundles.  Parsing for the following are fully implemented or partially implemented:

* Containers
    * FAT Binary ✔
    * DYLD Shared Cache (*needs further testing*)
* Mach-O
    * Header ✔
    * Load Commands ✔ *except*
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
        * LC_LINKER_OPTION
        * LC_LINKER_OPTIMIZATION_HINT
    * Segments and Sections ✔
        * Strings Section ✔
        * Pointer List Section ✔
        * Data Section ✔
        * Stubs Section ✔
        * Indirect Pointers Section ✔
    * Rebase Information ✔
        * Commands ✔
        * Fixups ✔
    * Bindings ✔
        * Standard ✔
        * Weak ✔
        * Lazy ✔
        * Threaded ✔ (*needs further testing*)
    * Exports Information ✔
    * Function Starts ✔
    * Segment Split Info
        * V1 ✔
    * Data in Code Entries ✔
    * Symbols ✔
        * STABS: *All stabs can be parsed by Mach-O Kit (because all stabs are symbols).  Specialized subclasses with refined API are only provided for the subset of stab types that are emitted by Apple's modern development tools.*
        * Undefined Symbols ✔
        * Common Symbols ✔
        * Absolute Symbols ✔
        * Section Symbols ✔
        * Alias Symbols ✔
    * Indirect Symbols ✔
* ObjC Metadata
    * Image Info ✔
    * Classes ✔
    * Protocols ✔
    * Methods ✔
    * Properties ✔
    * Instance Variables ✔
    * Categories ✔
    * ObjC-Specific Sections
        * `__objc_imageinfo` ✔
        * `__objc_selrefs` ✔
        * `__objc_superrefs` ✔
        * `__objc_protorefs` ✔
        * `__objc_classrefs` ✔
        * `__objc_classlist / __objc_nlclslist` ✔
        * `__objc_catlist / __objc_nlcatlist` ✔
        * `__objc_protolist` ✔
        * `__objc_ivar` ✔
        * `__objc_const` ✔
        * `__objc_data` ✔
* CF Data
	* CFString ✔
	* CF-Specific Sections
		* `__cfstring` ✔


## libMachO

libMachO is a lightweight, C library for safely parsing Mach-O images loaded into a process.  You can use libMachO to parse Mach-O images in your own process or any process that your process posses the task port for.  

As with Mach-O Kit, access to memory by libMachO is mediated by a memory map.  All memory access is checked to prevent parsing a malformed Mach-O image from crashing the parser.  Included are memory maps for reading from the current process or from a task port.  Any differences between the target architecture of the Mach-O image and the process hosting libMachO are handled transparently.

To keep the library lightweight libMachO overlays itself atop the Mach-O image and provides a set of APIs for reading the underlying Mach-O data structures.  libMachO does not build up its own independent representation of the Mach-O image, opting to continuously walk the Mach-O structures to access requested data.  A consequence of this design is that libMachO generally expects well-formed Mach-O images.

libMachO does not perform any dynamic memory allocation.  Clients are responsible for allocating buffers which are then initialized by the functions called in libMachO.  Consequently, the lifetimes of these buffers must be managed by clients.

## License

Mach-O Kit is released under the MIT license. See
[LICENSE.md](https://github.com/DeVaukz/MachO-Kit/blob/master/LICENSE).
