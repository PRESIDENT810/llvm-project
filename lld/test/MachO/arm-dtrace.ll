; RUN: rm -rf %t; split-file %s %t

; RUN: llvm-as %t/arm-dtrace.ll -o %t/arm-dtrace.ll.o
; RUN: %lld -demangle -dynamic -arch armv4t -platform_version macos 12.0.0 12.3 -o %t/arm-dtrace %t/arm-dtrace.ll.o

;; If references of dtrace symbols are handled by lld, their relocation should be replaced with the following instructions
; RUN: llvm-objdump --macho -D %t/arm-dtrace | FileCheck %s --check-prefix=CHECK

;; Check kindStoreARMDtraceIsEnableSiteClear
; CHECK: 00 00 20 e0  eor     r0, r0, r0

;; Check kindStoreARMDtraceCallSiteNop
; CHECK: 00 00 a0 e1  mov     r0, r0

;--- arm-dtrace.ll
source_filename = "main.cpp"
target datalayout = "e-m:o-p:32:32-Fi8-f64:32:64-v64:32:64-v128:32:128-a:0:32-n32-S32"
target triple = "armv4t-apple-macosx12.0.0"

define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %4 = call i32 @"__dtrace_isenabled$Foo$added$v1"()
  store i32 %4, i32* %2, align 4
  call void asm sideeffect "", ""() #2, !srcloc !6
  %5 = load i32, i32* %2, align 4
  store i32 %5, i32* %3, align 4
  %6 = load i32, i32* %3, align 4
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %11

8:                                                ; preds = %0
  br label %9

9:                                                ; preds = %8
  call void asm sideeffect ".reference ___dtrace_typedefs$$Foo$$v2", ""() #2, !srcloc !7
  call void @"__dtrace_probe$Foo$added$v1$696e74"(i32 0)
  call void asm sideeffect ".reference ___dtrace_stability$$Foo$$v1$$1_1_0_1_1_0_1_1_0_1_1_0_1_1_0", ""() #2, !srcloc !8
  br label %10

10:                                               ; preds = %9
  br label %11

11:                                               ; preds = %10, %0
  ret i32 0
}

declare i32 @"__dtrace_isenabled$Foo$added$v1"() #1

declare void @"__dtrace_probe$Foo$added$v1$696e74"(i32) #1

!6 = !{i64 2147497205}
!7 = !{i64 2147497248}
!8 = !{i64 2147497342}
