//===- Dtrace.h ----------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DTRACE_H
#define LLVM_DTRACE_H

#include "Symbols.h"
#include "Target.h"
#include "lld/Common/LLVM.h"

#include <dlfcn.h>
#include <vector>

namespace lld {
namespace macho {

extern std::vector<StringRef> dtraceProviderInfo;

bool checkDtraceProvider(StringRef name);

bool isDtraceSym(StringRef name);

void resolveDtraceSymbol(const Symbol *sym, const Reloc r, uint8_t *loc);

} // namespace macho
} // namespace lld

#endif // LLVM_DTRACE_H
