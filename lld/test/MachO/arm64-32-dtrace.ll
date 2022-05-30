; RUN: rm -rf %t; split-file %s %t

; RUN: llvm-as %t/arm64_32-dtrace.ll -o %t/arm64_32-dtrace.ll.o
; RUN: %lld -demangle -dynamic -arch arm64_32 -platform_version macos 12.0.0 12.3 -o %t/arm64_32-dtrace %t/arm64_32-dtrace.ll.o

;; If references of dtrace symbols are handled by lld, their relocation should be replaced with the following instructions
; RUN: llvm-objdump --macho -D %t/arm64_32-dtrace | FileCheck %s --check-prefix=CHECK

;; Check kindStoreARM64DtraceIsEnableSiteClear
; CHECK: 00 00 80 d2  mov     x0, #0

;; Check kindStoreARM64DtraceCallSiteNop
; CHECK: 1f 20 03 d5  nop

;--- arm64_32-dtrace.ll
source_filename = "main.cpp"
target datalayout = "e-m:o-p:32:32-i64:64-i128:128-n32:64-S128"
target triple = "arm64_32-apple-macosx12.0.0"

define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %4 = call i32 @"__dtrace_isenabled$Foo$added$v1"()
  store i32 %4, i32* %2, align 4
  call void asm sideeffect "", ""() #2, !srcloc !10
  %5 = load i32, i32* %2, align 4
  store i32 %5, i32* %3, align 4
  %6 = load i32, i32* %3, align 4
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %11

8:                                                ; preds = %0
  br label %9

9:                                                ; preds = %8
  call void asm sideeffect ".reference ___dtrace_typedefs$$Foo$$v2", ""() #2, !srcloc !11
  call void @"__dtrace_probe$Foo$added$v1$696e74"(i32 0)
  call void asm sideeffect ".reference ___dtrace_stability$$Foo$$v1$$1_1_0_1_1_0_1_1_0_1_1_0_1_1_0", ""() #2, !srcloc !12
  br label %10

10:                                               ; preds = %9
  br label %11

11:                                               ; preds = %10, %0
  ret i32 0
}

declare i32 @"__dtrace_isenabled$Foo$added$v1"() #1

declare void @"__dtrace_probe$Foo$added$v1$696e74"(i32) #1

!10 = !{i64 2147498363}
!11 = !{i64 2147498406}
!12 = !{i64 2147498500}
