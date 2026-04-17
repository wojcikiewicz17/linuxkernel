# SPDX-License-Identifier: GPL-2.0

obj-y += core_engine_modules.o

generated/detected.inc: detect_env.sh
	./detect_env.sh generated/detected.inc

core_engine_modules.o: generated/detected.inc
