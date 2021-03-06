## 
## EnduroX Platform Script Standard Library
##
## @file CMakeLists.txt
## 
## -----------------------------------------------------------------------------
## Enduro/X Middleware Platform for Distributed Transaction Processing
## Copyright (C) 2015, Mavimax, Ltd. All Rights Reserved.
## This software is released under one of the following licenses:
## GPL or Mavimax's license for commercial use.
## -----------------------------------------------------------------------------
## GPL license:
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT ANY
## WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
## PARTICULAR PURPOSE. See the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, write to the Free Software Foundation, Inc., 59 Temple
## Place, Suite 330, Boston, MA 02111-1307 USA
##
## -----------------------------------------------------------------------------
## A commercial use license is available from Mavimax, Ltd
## contact@mavimax.com
## -----------------------------------------------------------------------------
##

# Set minimum version
cmake_minimum_required(VERSION 2.8)

# Add debug options
# By default if RELEASE_BUILD is not defined, then we run in debug!
IF ($ENV{RELEASE_BUILD})
	# do nothing
ELSE ($ENV{RELEASE_BUILD})
	ADD_DEFINITIONS("-D NDRX_DEBUG")
ENDIF ($ENV{RELEASE_BUILD})


add_custom_command(
  OUTPUT WizardBase.c
  COMMAND embedfile WizardBase.pscript WizardBase
  DEPENDS WizardBase.pscript)

# Make sure the compiler can find include files from our UBF library.
include_directories (. ${ENDUROX_SOURCE_DIR}/include ${ENDUROX_SOURCE_DIR}/libnstd) 
# Create a library called "ATMI" which includes the source files.
# The extension is already found. Any number of sources could be listed here. 
add_library (psstdlib SHARED
        psstdsystem.cpp
        psstdstring.cpp
        psstdstream.cpp
        psstdrex.cpp
        psstdmath.cpp
        psstdio.cpp
        psstdblob.cpp
        psstdaux.cpp
        psstdexutil.cpp
        WizardBase.c
            )

if(${CMAKE_OS_NAME} STREQUAL "CYGWIN")
    target_link_libraries(psstdlib ps nstd)
elseif(${CMAKE_OS_NAME} STREQUAL "DARWIN")
    target_link_libraries(psstdlib ps nstd)
endif()

install (TARGETS 
    psstdlib
    DESTINATION "${INSTALL_LIB_DIR}"
    PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE
    COMPONENT libraries)

