; RUN: rm -rf %t; split-file %s %t

; RUN: llvm-as %t/x86_64-dtrace.ll -o %t/x86_64-dtrace.ll.o
; RUN: %lld -demangle -dynamic -arch x86_64 -platform_version macos 12.0.0 12.3 -o %t/x86_64-dtrace %t/x86_64-dtrace.ll.o

;; If references of dtrace symbols are handled by lld, their relocation should be replaced with the following instructions
; RUN: llvm-objdump --macho -D %t/x86_64-dtrace | FileCheck %s --check-prefix=CHECK

;; Check kindStoreX86DtraceIsEnableSiteClear
; CHECK: 33 c0                        xorl    %eax, %eax
; CHECK: 90                           nop
; CHECK: 90                           nop
; CHECK: 90                           nop

;; Check kindStoreX86DtraceCallSiteNop
; CHECK: 90                           nop
; CHECK: 0f 1f 40 00                  nopl    (%rax)

;--- x86_64-dtrace.ll
source_filename = "main.cpp"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx12.0.0"

define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %4 = call i32 @"__dtrace_isenabled$Foo$added$v1"()
  store i32 %4, i32* %2, align 4
  call void asm sideeffect "", "~{dirflag},~{fpsr},~{flags}"() #2, !srcloc !6
  %5 = load i32, i32* %2, align 4
  store i32 %5, i32* %3, align 4
  %6 = load i32, i32* %3, align 4
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %11

8:                                                ; preds = %0
  br label %9

9:                                                ; preds = %8
  call void asm sideeffect ".reference ___dtrace_typedefs$$Foo$$v2", "~{dirflag},~{fpsr},~{flags}"() #2, !srcloc !7
  call void @"__dtrace_probe$Foo$added$v1$696e74"(i32 0)
  call void asm sideeffect ".reference ___dtrace_stability$$Foo$$v1$$1_1_0_1_1_0_1_1_0_1_1_0_1_1_0", "~{dirflag},~{fpsr},~{flags}"() #2, !srcloc !8
  br label %10

10:                                               ; preds = %9
  br label %11

11:                                               ; preds = %10, %0
  ret i32 0
}

declare i32 @"__dtrace_isenabled$Foo$added$v1"() #1

declare void @"__dtrace_probe$Foo$added$v1$696e74"(i32) #1

!6 = !{i64 2147497742}
!7 = !{i64 2147497785}
!8 = !{i64 2147497879}
