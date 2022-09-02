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
  # CMAKE_CXX_COMPILER_ID - actual compiler used
  # CMAKE_CXX_SIMULATE_ID - compiler simulated ABI
  # CMAKE_CXX_COMPILER_FRONTEND_VARIANT - compiler simulated front-end
  message(STATUS "CMake(${CMAKE_VERSION}) compiler=${CMAKE_CXX_COMPILER_ID}(${CMAKE_CXX_COMPILER_VERSION}), ABI=${CMAKE_CXX_SIMULATE_ID}(${CMAKE_CXX_SIMULATE_VERSION}), front-end=${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}")

  if (${CMAKE_VERSION} VERSION_LESS "3.15.0")
    message(FATAL_ERROR "Please consider to switch to CMake >= 3.15.0")
  endif()

  # COMPILER_ID - compiler ABI (real or simulated)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
      set(COMPILER_ID "MSVC")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_SIMULATE_ID STREQUAL "GNU")
      set(COMPILER_ID "GNU")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" OR CMAKE_CXX_SIMULATE_ID STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER STREQUAL "clang")
      set(COMPILER_ID "LLVM")
  else()
      message(FATAL_ERROR "Unknown compiler ID")
  endif()

  # COMPILER_FRONTEND - compiler front-end (real or simulated)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
      set(COMPILER_FRONTEND "MSVC")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
      set(COMPILER_FRONTEND "GNU")
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER_ID STREQUAL "clang") 
      set(COMPILER_FRONTEND "LLVM")
  else()
      message(FATAL_ERROR "Unknown compiler front-end")
  endif()

  # COMPILER_TOOLSET - compiler toolset (if available)
  if(COMPILER_ID STREQUAL "MSVC")
      # Using MSVC_TOOLSET_VERSION is not reliable, so test MSVC_VERSION like auto_link.h does.
      if(MSVC_VERSION)
          if(MSVC_VERSION GREATER_EQUAL "1910" AND MSVC_VERSION LESS "1920")
              set(COMPILER_TOOLSET "v141")
          elseif((MSVC_VERSION GREATER_EQUAL "1920" AND MSVC_VERSION LESS "1930"))
              set(COMPILER_TOOLSET "v142")
      elseif((MSVC_VERSION GREATER_EQUAL "1930" AND MSVC_VERSION LESS "1940"))
        set(COMPILER_TOOLSET "v143")
          else()
              message(FATAL_ERROR "Unknown MSVC_VERSION, ${MSVC_VERSION}")
          endif()
      else()
          message(FATAL_ERROR "MSVC_VERSION is not defined")
      endif()
  elseif(COMPILER_ID STREQUAL "GNU")
      # No toolset variants
  elseif(COMPILER_ID STREQUAL "LLVM")
      # No toolset variants
  else()
      message(FATAL_ERROR "Unexpected proj compiler ID, ${COMPILER_ID}")
  endif()

  message(STATUS "Proj compiler=${COMPILER_ID}, toolset=${COMPILER_TOOLSET}, path=${CMAKE_CXX_COMPILER}")

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
  if (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "x64|amd64.*|x86_64.*")
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
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "parisc*")
    set(TARGET_ARCH "PPC64")
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "ppc")
    set(TARGET_HPPA 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "s390")
    set(TARGET_S390 1)
  elseif(LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "s390x")
    set(TARGET_S390X 1)
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "mips64")
    set(TARGET_ARCH "mips64")
    set(TARGET_MIPS 1)
    set(TARGET_MIPS64 1)
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "alpha*")
    set(TARGET_ALPHA 1)
  elseif (LOWERCASE_CMAKE_SYSTEM_PROCESSOR MATCHES "sh4")
    set(TARGET_SH4 1)
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
  # CMake 3.15 has added support for both the clang-cl 
  # and the regular clang front end. 
  # You can determine the front end variant by inspecting the variable CMAKE_<LANG>_COMPILER_FRONTEND_VARIANT
  #
  # The clang-cl on Windows has CMAKE_CXX_SIMULATE_ID = MSVC 
  # and will generate code that can link with code generated by other MSVC compilers, like Visual Studio. 
  # Since, clang's CMAKE_CXX_COMPILER_FRONTEND_VARIANT is GNU 
  # it will take the gnu-style command line options.
  # CMAKE_<LANG>_SIMULATE_ID is telling what kind of ABI compatibility the generated code will have, 
  # whereas CMAKE_<LANG>_COMPILER_FONTEND_VARIANT describes what command line options 
  # and language extensions the compiler frontend expects.
  #
  # Example:
  #  target_compile_options(
  #    lambda-tuple-compile-options
  #    INTERFACE
  #        $<$<OR:$<CXX_COMPILER_ID:GNU>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>>:-fsanitize=undefined,address
  #        -fno-omit-frame-pointer>
  #        $<$<OR:$<CXX_COMPILER_ID:MSVC>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>>:/fsanitize=address>)
  #
  set(MSVC_LIKE OFF)
  set(IS_CLANG_FRONTEND OFF)
  set(IS_GNU_FRONTEND OFF)
  if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.15.0") 
    if(MSVC OR CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        set(MSVC_LIKE ON)
    endif()
    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
      if (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        # using clang with clang-cl front end
        set(IS_CLANG_FRONTEND ON)
        set(COMPILER_IS_CLANG_CL ON)
        set(IS_CLANG_CL ON)
        set(COMPILER_IS_CLANG OFF)
        set(IS_CLANG OFF)
      elseif (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
        # using clang with regular front end
        set(IS_GNU_FRONTEND ON)
        set(COMPILER_IS_CLANG_CL OFF)
        set(IS_CLANG_CL OFF)
        set(COMPILER_IS_CLANG ON)
        set(IS_CLANG ON)
      endif()
    endif()
  else()
    message(FATAL_ERROR "Please consider to switch to CMake >= 3.15.0")
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
