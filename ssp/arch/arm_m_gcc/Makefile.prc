#
#  @(#) $Id: Makefile.prc 1304 2008-08-27 07:28:36Z ertl-honda $
# 

#
#		Makefile のプロセッサ依存部（ARM-M用）
#

#
#  コンパイルオプション
#
COPTS := $(COPTS) -mthumb 
INCLUDES := $(INCLUDES) -I$(SRCDIR)/arch/$(PRC)_$(TOOL)/
LDFLAGS := -nostdlib $(LDFLAGS) 
CDEFS := $(CDEFS) -DTOPPERS_LABEL_ASM
LIBS := $(LIBS)  -lgcc

#
#  カーネルに関する定義
#
KERNEL_DIR := $(KERNEL_DIR) $(SRCDIR)/arch/$(PRC)_$(TOOL)
KERNEL_ASMOBJS := $(KERNEL_ASMOBJS) prc_support.o
KERNEL_COBJS := $(KERNEL_COBJS) prc_config.o prc_timer.o

#
#  コンフィギュレータ関係の変数の定義
#
CFG_TABS := $(CFG_TABS) --cfg1-def-table $(SRCDIR)/arch/$(PRC)_$(TOOL)/prc_def.csv

#
#  依存関係の定義
#
cfg1_out.c: $(SRCDIR)/arch/$(PRC)_$(TOOL)/prc_def.csv
kernel_cfg.timestamp: $(SRCDIR)/arch/$(PRC)_$(TOOL)/prc.tf
