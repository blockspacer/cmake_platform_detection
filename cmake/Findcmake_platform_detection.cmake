# cmake utils

#
# TODO: use set_cpd_var with CUSTOM_PREFIX to prevent variable collisions
#
#macro(set_cpd_var NAME VALUE)
#  set(options ${NAME} ${VALUE})
#endmacro(set_cpd_var)

#
# USAGE:
#  run_cmake_platform_detection()
#
macro(run_cmake_platform_detection)
  set(TARGET_PLATFORM_DETECTED FALSE)
  if (UNIX)
    set(PLATFORM_UNIX TRUE)
  endif(UNIX)
  #
  if(${CMAKE_SYSTEM_NAME} STREQUAL "Emscripten" OR EMSCRIPTEN OR FORCE_AS_EMSCRIPTEN_PLATFORM)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_WEB TRUE)
    set(TARGET_EMSCRIPTEN TRUE)
  elseif(${CMAKE_SYSTEM_NAME} MATCHES "Fuchsia" OR FORCE_AS_FUCHSIA_PLATFORM)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_DESKTOP TRUE)
    set(TARGET_FUCHSIA TRUE)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux" OR FORCE_AS_LINUX_PLATFORM)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_DESKTOP TRUE)
    set(TARGET_LINUX TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "^k?P?NaCl*$") # PNaCl, NaCl32, NaCl64, etc.
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_WEB TRUE)
    set(TARGET_NACL TRUE)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Windows" OR FORCE_AS_WINDOWS_PLATFORM)
    set(OS_WIN TRUE)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_DESKTOP TRUE)
    set(TARGET_WINDOWS TRUE)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Android" OR FORCE_AS_ANDROID_PLATFORM)
    set(OS_ANDROID TRUE)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_MOBILE TRUE)
    set(TARGET_ANDROID TRUE)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "iOS" OR FORCE_AS_IOS_PLATFORM)
    set(OS_IOS TRUE)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_MOBILE TRUE)
    set(TARGET_IOS TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "^k?FreeBSD$") # FreeBSD, kFreeBSD, etc.
    set(OS_FREEBSD TRUE)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_DESKTOP TRUE)
    set(TARGET_LINUX TRUE)
  elseif(CMAKE_SYSTEM_NAME MATCHES "^OpenBSD$")
    set(OS_OPENBSD TRUE)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_DESKTOP TRUE)
    set(TARGET_LINUX TRUE)
  elseif(${CMAKE_SYSTEM_NAME} STREQUAL "MacOS" OR ${CMAKE_SYSTEM_NAME} STREQUAL "Darwin" OR FORCE_AS_DARWIN_PLATFORM)
    set(OS_MAC TRUE)
    set(TARGET_PLATFORM_DETECTED TRUE)
    set(PLATFORM_DESKTOP TRUE)
    set(TARGET_MACOS TRUE)
  else()
    set(TARGET_PLATFORM_DETECTED FALSE)
    set(TARGET_UNKNOWN TRUE)
    message(FATAL_ERROR "(run_cmake_platform_detection) platform=${CMAKE_SYSTEM_NAME} not supported")
  endif()
  #
  if(TARGET_IOS OR TARGET_MACOS)
    set(TARGET_APPLE TRUE)
  endif()
  if(TARGET_LINUX OR TARGET_IOS OR TARGET_MACOS OR TARGET_ANDROID)
    set(TARGET_POSIX TRUE)
  endif()
  #
  set(is_apple ${TARGET_APPLE})
  set(IS_APPLE ${TARGET_APPLE})
  #
  set(TARGET_MAC ${TARGET_MACOS})
  set(is_mac ${TARGET_MACOS})
  set(IS_MAC ${TARGET_MACOS})
  #
  set(is_posix ${TARGET_POSIX})
  set(IS_POSIX ${TARGET_POSIX})
  #
  set(is_android ${TARGET_ANDROID})
  set(IS_ANDROID ${TARGET_ANDROID})
  #
  set(is_ios ${TARGET_IOS})
  set(IS_IOS ${TARGET_IOS})
  #
  set(is_linux ${TARGET_LINUX})
  set(IS_LINUX ${TARGET_LINUX})
  #
  set(is_unix ${TARGET_UNIX})
  set(IS_UNIX ${TARGET_UNIX})
  #
  set(is_nacl ${TARGET_NACL})
  set(IS_NACL ${TARGET_NACL})
  #
  set(TARGET_WIN ${TARGET_WINDOWS})
  set(is_win ${TARGET_WINDOWS})
  set(IS_WIN ${TARGET_WINDOWS})
  set(is_windows ${TARGET_WINDOWS})
  set(IS_WINDOWS ${TARGET_WINDOWS})
  #
  set(is_fuchsia ${TARGET_FUCHSIA})
  set(IS_FUCHSIA ${TARGET_FUCHSIA})
  #
  set(is_emscripten ${TARGET_EMSCRIPTEN})
  set(IS_EMSCRIPTEN ${TARGET_EMSCRIPTEN})
  #
  set(is_mobile ${PLATFORM_MOBILE})
  set(IS_MOBILE ${PLATFORM_MOBILE})
  #
  set(is_web ${PLATFORM_WEB})
  set(IS_WEB ${PLATFORM_WEB})
  #
  set(is_desktop ${PLATFORM_DESKTOP})
  set(IS_DESKTOP ${PLATFORM_DESKTOP})
  #
  # Use MSVC_CXX_ARCHITECTURE_ID instead of CMAKE_SYSTEM_PROCESSOR when defined,
  # since the later one just resolves to the host processor on Windows.
  if (MSVC_CXX_ARCHITECTURE_ID)
      string(TOLOWER ${MSVC_CXX_ARCHITECTURE_ID} LOWERCASE_CMAKE_SYSTEM_PROCESSOR)
  else ()
      string(TOLOWER ${CMAKE_SYSTEM_PROCESSOR} LOWERCASE_CMAKE_SYSTEM_PROCESSOR)
  endif ()
  #
  if (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "amd64.*|x86_64.*")
    set(TARGET_ARCH "x86_64")
    set(TARGET_X86_64 1)
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "AMD64")
    # cmake reports AMD64 on Windows, but we might be building for 32-bit.
    if (CMAKE_CL_64)
      set(TARGET_ARCH "x86_64")
      set(TARGET_X86_64 1)
    else()
      set(TARGET_ARCH "x86")
      set(TARGET_X86 1)
    endif()
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "(i[3-6]86|x86)")
    set(TARGET_ARCH "x86")
    set(TARGET_X86 1)
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm.*|ARM.*)")
    set(TARGET_ARCH "arm")
    set(TARGET_ARM 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)64le")
    set(TARGET_ARCH "PPC64LE")
    set(TARGET_PPC64LE 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)64")
    set(TARGET_ARCH "PPC64")
    set(TARGET_PPC64 1)
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "mips64")
    set(TARGET_ARCH "mips64")
    set(TARGET_MIPS 1)
    set(TARGET_MIPS64 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "^(mips.*|MIPS.*)")
    set(TARGET_ARCH "MIPS")
    set(TARGET_MIPS 1)
    set(TARGET_MIPS32 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64.*|AARCH64.*|arm64.*|ARM64.*)")
    set(TARGET_ARCH "AARCH64")
    set(TARGET_AARCH64 1)
    set(TARGET_ARM64 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "^(riscv.*|RISCV.*)")
    set(TARGET_ARCH "RISCV")
    set(TARGET_RISCV 1)
  else()
    message(FATAL_ERROR "Unknown processor:" ${LOWERCASE_CMAKE_SYSTEM_PROCESSOR})
  endif()
  if (${TARGET_ARCH} STREQUAL "x86" AND APPLE)
    # With CMake 2.8.x, ${LOWERCASE_CMAKE_SYSTEM_PROCESSOR} evalutes to i386 on OS X,
    # but clang defaults to 64-bit builds on OS X unless otherwise told.
    # Set ARCH to x86_64 so clang and CMake agree. This is fixed in CMake 3.
    set(TARGET_ARCH "x86_64")
    set(TARGET_X86_64 1)
  endif()
  # -----------------------------------------------------------------------------
  # Determine the compiler
  # -----------------------------------------------------------------------------
  if (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
    set(COMPILER_IS_CLANG ON)
    set(IS_CLANG ON)
  endif()
  #
  if (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    set(COMPILER_IS_GCC 1)
    set(IS_GCC 1)
    if (${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS "7.3.0")
      message(FATAL_ERROR "GCC 7.3 or newer is required. Use a newer GCC version or Clang.")
    endif()
  endif()
  #
  if (CMAKE_COMPILER_IS_GNUCXX OR COMPILER_IS_CLANG)
    set(COMPILER_IS_GCC_OR_CLANG ON)
    set(IS_GCC_OR_CLANG ON)
  endif()
  #
  if (MSVC AND COMPILER_IS_CLANG)
    set(COMPILER_IS_CLANG_CL ON)
    set(IS_CLANG_CL ON)
  endif()
  #
  string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type_tolower)
  if(cmake_build_type_tolower MATCHES "debug")
    set(IS_DEBUG TRUE)
    set(IS_RELEASE FALSE)
  elseif(cmake_build_type_tolower MATCHES "release")
    set(IS_DEBUG FALSE)
    set(IS_RELEASE TRUE)
  endif()
  set(is_debug ${IS_DEBUG})
  set(is_release ${IS_RELEASE})
endmacro(run_cmake_platform_detection)

#
# USAGE:
#  restrict_supported_platforms(LINUX EMSCRIPTEN WINDOWS)
#
# NOTE: requires before usage run_cmake_platform_detection()
#
macro(restrict_supported_platforms)
  set(options TARGETS WINDOWS LINUX EMSCRIPTEN)
  cmake_parse_arguments(ARGUMENTS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  if(NOT TARGET_PLATFORM_DETECTED)
    message(FATAL_ERROR "platform=${CMAKE_SYSTEM_NAME} not supported. Maybe you forgot to use run_cmake_platform_detection?")
  endif()

  if(ARGUMENTS_WINDOWS AND TARGET_WINDOWS)
    # skip
  elseif(ARGUMENTS_LINUX AND TARGET_LINUX)
    # skip
  elseif(ARGUMENTS_EMSCRIPTEN AND TARGET_EMSCRIPTEN)
    # skip
  else()
    message(FATAL_ERROR "(restrict_supported_platforms) platform=${CMAKE_SYSTEM_NAME} not supported.")
  endif()
endmacro(restrict_supported_platforms)
