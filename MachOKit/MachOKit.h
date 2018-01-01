//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//! @file       MachOKit.h
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2014-2015 D.V. All rights reserved.
//!
//! @brief
//! The root include for MachOKit.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#ifndef _MachOKit_H
#define _MachOKit_H

#include <MachOKit/macho.h>

#import <MachOKit/NSError+MK.h>

#import <MachOKit/MKNodeDescription.h>
#import <MachOKit/MKMemoryMap.h>
#import <MachOKit/MKOptional.h>
#import <MachOKit/MKDataModel.h>
#import <MachOKit/MKNode.h>
#import <MachOKit/MKAddressedNode.h>
#import <MachOKit/MKBackedNode.h>
#import <MachOKit/MKOffsetNode.h>

#import <MachOKit/MKNodeFieldCPUType.h>
#import <MachOKit/MKNodeFieldCPUSubType.h>

#import <MachOKit/MKBackedNode+Pointer.h>
#import <MachOKit/MKPointer.h>
#import <MachOKit/MKPointerNode.h>
#import <MachOKit/MKCString.h>

#import <MachOKit/MKFatBinary.h>
#import <MachOKit/MKFatArch.h>

#import <MachOKit/MKSharedCache.h>
#import <MachOKit/MKDSCHeader.h>
#import <MachOKit/MKDSCMappingInfo.h>
#import <MachOKit/MKDSCMapping.h>
#import <MachOKit/MKSharedCache+Images.h>
    #import <MachOKit/MKDSCImagesInfo.h>
    #import <MachOKit/MKDSCImage.h>
#import <MachOKit/MKSharedCache+Slide.h>
    #import <MachOKit/MKDSCSlideInfo.h>
    #import <MachOKit/MKDSCSlideInfoHeader.h>
    #import <MachOKit/MKDSCSlideInfoBitmap.h>
    #import <MachOKit/MKDSCSlideInfoPage.h>
    #import <MachOKit/MKDSCSlidPointer.h>
#import <MachOKit/MKSharedCache+Symbols.h>
    #import <MachOKit/MKDSCLocalSymbols.h>
    #import <MachOKit/MKDSCLocalSymbolsHeader.h>
    #import <MachOKit/MKDSCSymbolTable.h>
    #import <MachOKit/MKDSCSymbol.h>
    #import <MachOKit/MKDSCStringTable.h>
    #import <MachOKit/MKDSCDylibInfos.h>
    #import <MachOKit/MKDSCDylibSymbolInfo.h>

#import <MachOKit/MKMachO.h>
#import <MachOKit/MKMachO+Segments.h>
#import <MachOKit/MKMachO+Symbols.h>
#import <MachOKit/MKMachHeader.h>
#import <MachOKit/MKMachHeader64.h>
#import <MachOKit/MKLoadCommand.h>
    #import <MachOKit/MKDylibLoadCommand.h>
    #import <MachOKit/MKDylinkerLoadCommand.h>
    #import <MachOKit/MKLinkEditDataLoadCommand.h>
    #import <MachOKit/MKMinVersionLoadCommand.h>
    #import <MachOKit/MKLCSegment.h>
    #import <MachOKit/MKLCSymtab.h>
    #import <MachOKit/MKLCDysymtab.h>
    #import <MachOKit/MKLCLoadDylib.h>
    #import <MachOKit/MKLCIDDylib.h>
    #import <MachOKit/MKLCLoadDylinker.h>
    #import <MachOKit/MKLCIDDylinker.h>
    #import <MachOKit/MKLCRoutines.h>
    #import <MachOKit/MKLCSubFramework.h>
    #import <MachOKit/MKLCSubClient.h>
    #import <MachOKit/MKLCSubLibrary.h>
    #import <MachOKit/MKLCTwoLevelHints.h>
    #import <MachOKit/MKLCPrebindChecksum.h>
    #import <MachOKit/MKLCLoadWeakDylib.h>
    #import <MachOKit/MKLCSegment64.h>
    #import <MachOKit/MKLCRoutines64.h>
    #import <MachOKit/MKLCUUID.h>
    #import <MachOKit/MKLCRPath.h>
    #import <MachOKit/MKLCCodeSignature.h>
    #import <MachOKit/MKLCSegmentSplitInfo.h>
    #import <MachOKit/MKLCReExportDylib.h>
    #import <MachOKit/MKLCEncryptionInfo.h>
    #import <MachOKit/MKLCDyldInfo.h>
    #import <MachOKit/MKLCDyldInfoOnly.h>
    #import <MachOKit/MKLCLoadUpwardDylib.h>
    #import <MachOKit/MKLCVersionMinMacOSX.h>
    #import <MachOKit/MKLCVersionMiniPhoneOS.h>
    #import <MachOKit/MKLCFunctionStarts.h>
    #import <MachOKit/MKLCDyldEnvironment.h>
    #import <MachOKit/MKLCMain.h>
    #import <MachOKit/MKLCDataInCode.h>
    #import <MachOKit/MKLCSourceVersion.h>
    #import <MachOKit/MKLCDylibCodeSignDrs.h>
    #import <MachOKit/MKLCEncryptionInfo64.h>
    #import <MachOKit/MKLCVersionMinTVOS.h>
    #import <MachOKit/MKLCVersionMinWatchOS.h>
    #import <MachOKit/MKLCNote.h>
    #import <MachOKit/MKLCBuildVersion.h>
#import <MachOKit/MKMachO+Libraries.h>
    #import <MachOKit/MKDependentLibrary.h>
#import <MachOKit/MKSegment.h>
#import <MachOKit/MKSection.h>
    #import <MachOKit/MKCStringSection.h>
    #import <MachOKit/MKPointerListSection.h>
    #import <MachOKit/MKDataSection.h>
    #import <MachOKit/MKStubsSection.h>
    #import <MachOKit/MKIndirectPointersSection.h>
#import <MachOKit/MKMachO+Rebase.h>
    #import <MachOKit/MKRebaseInfo.h>
    #import <MachOKit/MKFixup.h>
    #import <MachOKit/MKRebaseCommand.h>
    #import <MachOKit/MKRebaseDone.h>
    #import <MachOKit/MKRebaseSetTypeImmediate.h>
    #import <MachOKit/MKRebaseSetSegmentAndOffsetULEB.h>
    #import <MachOKit/MKRebaseAddAddressULEB.h>
    #import <MachOKit/MKRebaseAddAddressImmediateScaled.h>
    #import <MachOKit/MKRebaseDoRebaseImmediateTimes.h>
    #import <MachOKit/MKRebaseDoRebaseULEBTimes.h>
    #import <MachOKit/MKRebaseDoRebaseAddAddressULEB.h>
    #import <MachOKit/MKRebaseDoRebaseULEBTimesSkippingULEB.h>
#import <MachOKit/MKStringTable.h>
#import <MachOKit/MKSymbolTable.h>
#import <MachOKit/MKMachO+Bindings.h>
    #import <MachOKit/MKBindingsInfo.h>
    #import <MachOKit/MKWeakBindingsInfo.h>
    #import <MachOKit/MKLazyBindingsInfo.h>
    #import <MachOKit/MKBindAction.h>
    #import <MachOKit/MKBindCommand.h>
    #import <MachOKit/MKBindDone.h>
    #import <MachOKit/MKBindSetDylibOrdinalImmediate.h>
    #import <MachOKit/MKBindSetDylibOrdinalULEB.h>
    #import <MachOKit/MKBindSetDylibSpecialImmediate.h>
    #import <MachOKit/MKBindSetSymbolAndFlags.h>
    #import <MachOKit/MKBindSetTypeImmediate.h>
    #import <MachOKit/MKBindSetAddendSLEB.h>
    #import <MachOKit/MKBindSetSegmentAndOffsetULEB.h>
    #import <MachOKit/MKBindAddAddressULEB.h>
    #import <MachOKit/MKBindDoBind.h>
    #import <MachOKit/MKBindDoBindAddAddressULEB.h>
    #import <MachOKit/MKBindDoBindAddAddressImmediateScaled.h>
    #import <MachOKit/MKBindDoBindULEBTimesSkippingULEB.h>
    #import <MachOKit/MKSymbol.h>
#import <MachOKit/MKIndirectSymbolTable.h>
    #import <MachOKit/MKIndirectSymbol.h>

#import <MachOKit/MKObjCElementList.h>
#import <MachOKit/MKObjCImageInfo.h>
#import <MachOKit/MKObjCClass.h>
#import <MachOKit/MKObjCClassData.h>
#import <MachOKit/MKObjCProtocolList.h>
#import <MachOKit/MKObjCProtocol.h>
#import <MachOKit/MKObjCProtocolMethodTypesList.h>
#import <MachOKit/MKObjCClassMethodList.h>
#import <MachOKit/MKObjCClassMethod.h>
#import <MachOKit/MKObjCClassPropertyList.h>
#import <MachOKit/MKObjCClassProperty.h>
#import <MachOKit/MKObjCClassIVarList.h>
#import <MachOKit/MKObjCClassIVar.h>
#import <MachOKit/MKObjCIVarOffset.h>
#import <MachOKit/MKObjCCategory.h>
    #import <MachOKit/MKObjCImageInfoSection.h>
    #import <MachOKit/MKObjCSelectorReferencesSection.h>
    #import <MachOKit/MKObjCSuperReferencesSection.h>
    #import <MachOKit/MKObjCProtocolReferencesSection.h>
    #import <MachOKit/MKObjCClassReferencesSection.h>
    #import <MachOKit/MKObjCClassListSection.h>
    #import <MachOKit/MKObjCCategoryListSection.h>
    #import <MachOKit/MKObjCProtocolListSection.h>
    #import <MachOKit/MKObjCIVarSection.h>
    #import <MachOKit/MKObjCConstSection.h>
    #import <MachOKit/MKObjCDataSection.h>

#endif /* _MachOKit_H */
