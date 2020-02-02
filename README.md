# Kojin

Support for code generation.

Initial focus on modeling plain old data and generating rust. 
Based on previous tools that became unusable after
Dart 1.0 moved to Dart 2.0 and switched from a more traditional scripting language
with fast startup to an AOT type language with very slow startup in the case of
code changes. There are solutions to make Dart 2.0 startup quickly if your code
is stable - but if you have an iteration cycle of change code, run, change code
run, etc - that cycle time grew to be unmanageable due to startup and ahead
of time compilation.

- [ebisu](https://github.com/patefacio/ebisu): The core, shared library
- [ebisu-pod](https://github.com/patefacio/ebisu_pod): Support for modeling plain old data in native
    dart with IDL like definitions
- [ebisu-cpp](https://github.com/patefacio/ebisu_cpp): Support for generating C++
- [ebisu-rs](https://github.com/patefacio/ebisu_rs)]: Support for generating Rust


