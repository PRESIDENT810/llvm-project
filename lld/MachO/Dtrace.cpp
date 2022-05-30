//===- Dtrace.cpp ----------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Dtrace.h"

using namespace lld;
using namespace lld::macho;
using namespace llvm;
using namespace llvm::MachO;

// Prototype for entry point in libdtrace.dylib
typedef uint8_t *(*createdof_func_t)(
    // [provided by linker] target architecture
    CPUType cpu,
    // [provided by linker] number of stability or typedef symbol names
    unsigned int typeCount,
    // [provided by linker] stability or typedef symbol names
    const char *typeNames[],
    // [provided by linker] number of probe or isenabled locations
    unsigned int probeCount,
    // [provided by linker] probe or isenabled symbol names
    const char *probeNames[],
    // [provided by linker] function name containing probe or isenabled
    const char *probeWithin[],
    // [allocated by linker, populated by DTrace] per-probe offset in the DOF
    uint64_t offsetsInDOF[],
    // [allocated by linker, populated by DTrace] size of the DOF)
    size_t *size);

std::vector<StringRef> lld::macho::dtraceProviderInfo;

bool lld::macho::checkDtraceProvider(StringRef name){
  if (name.substr(0, 10) == "___dtrace_") {
    if (name.substr(10, 6) != "probe$" && name.substr(10, 10) != "isenabled$") {
      dtraceProviderInfo.push_back(name);
    }
    return true;
  }
  return false;
}

bool lld::macho::isDtraceSym(StringRef name){
  if (name.substr(0, 10) == "___dtrace_") {
    return true;
  }
  return false;
}

void lld::macho::resolveDtraceSymbol(const Symbol *sym, const Reloc r, uint8_t *loc) {
  // Dtrace symbol should be undefined
  assert(sym && isa<Undefined>(sym));

  switch (target->cpuType){
  case CPU_TYPE_X86_64:
  case CPU_TYPE_ARM:
  case CPU_TYPE_ARM64:
  case CPU_TYPE_ARM64_32:
    target->handleDtraceReloc(sym, r, loc);
    break;
  default:
    error("Unsupported architecture for dtrace symbols");
    break;
  }
}