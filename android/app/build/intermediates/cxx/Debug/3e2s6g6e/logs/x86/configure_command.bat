@echo off
"C:\\Users\\cdcib\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=21" ^
  "-DANDROID_PLATFORM=android-21" ^
  "-DANDROID_ABI=x86" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86" ^
  "-DANDROID_NDK=C:\\Users\\cdcib\\AppData\\Local\\Android\\sdk\\ndk\\26.3.11579264" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\cdcib\\AppData\\Local\\Android\\sdk\\ndk\\26.3.11579264" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\cdcib\\AppData\\Local\\Android\\sdk\\ndk\\26.3.11579264\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\cdcib\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=D:\\2 Projects\\EventManagement\\android\\app\\build\\intermediates\\cxx\\Debug\\3e2s6g6e\\obj\\x86" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=D:\\2 Projects\\EventManagement\\android\\app\\build\\intermediates\\cxx\\Debug\\3e2s6g6e\\obj\\x86" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BD:\\2 Projects\\EventManagement\\android\\app\\.cxx\\Debug\\3e2s6g6e\\x86" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
