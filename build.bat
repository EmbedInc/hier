@echo off
rem
rem   Build everything from this source directory.
rem
setlocal
call godir "(cog)source/hier"

call build_lib
