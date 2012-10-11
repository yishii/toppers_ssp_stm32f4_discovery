$ 
$ バナー出力用のテンプレートファイル
$ 
$FILE "kernel_cfg.c"$

$ カーネル名称
$KERNEL_NAME = "\"TOPPERS/SSP Kernel \""$

$ バージョンの取り出し

$MAJOR_VERSION = ((TKERNEL_PRVER >> 12) & 0x0f)$
$MINOR_VERSION = ((TKERNEL_PRVER >> 4) & 0xff)$
$PATCH_VERSION = ((TKERNEL_PRVER & 0x0f) & 0x0f)$

$ 開発者
$AUTHOR = "\t\t\"Copyright (C) 2010 by Meika Sugimoto\\n\"\t\\\n"$
$AUTHOR	= CONCAT(AUTHOR , "\t\t\"Copyright (C) 2010 by Naoki Saito\\n\"\t\\\n")$
$AUTHOR	= CONCAT(AUTHOR , "\t\t\"            Nagoya Municipal Industrial Research Institute, JAPAN\\n\"\t\\\n")$

$BANNER = CONCAT("\"\\n\" " , KERNEL_NAME)$
$BANNER = CONCAT(BANNER , FORMAT(" \"%d.%X.%d \" \t\\\n" , MAJOR_VERSION , MINOR_VERSION , PATCH_VERSION))$
$BANNER = CONCAT(BANNER , "\t\t\" for \" TARGET_NAME ")$
$BANNER = CONCAT(BANNER , "\" (\" __DATE__ \" , \" __TIME__ \")\\n\"\t\\\n")$
$BANNER = CONCAT(BANNER , CONCAT(AUTHOR , "\t\tTARGET_COPYRIGHT \"\\n\""))$

$NL$
$NL$

#ifndef TARGET_COPYRIGHT$NL$
#define TARGET_COPYRIGHT$NL$
#endif /* TARGET_COPYRIGHT */$NL$
$NL$
$NL$
const char banner[] = $BANNER$;$NL$
const int32_t banner_size = sizeof(banner) / sizeof(banner[0]);
$NL$
$NL$
