$ 
$     パス2のアーキテクチャ依存テンプレート（ARM-M用）
$ 

$ 
$  有効な割込み番号，割込みハンドラ番号
$ 
$INTNO_VALID = RANGE(15, TMAX_INTNO)$
$INHNO_VALID = INTNO_VALID$

$ 
$  有効なCPU例外番号
$ 
$EXCNO_VALID = { 2,3,4,5,6,11,12,14 }$

$ 
$  ATT_ISRで使用できる割込み番号とそれに対応する割込みハンドラ番号
$ 
$INTNO_ATTISR_VALID = INTNO_VALID$
$INHNO_ATTISR_VALID = INHNO_VALID$

$ 
$  DEF_INT／DEF_EXCで使用できる割込みハンドラ番号／CPU例外ハンドラ番号
$ 
$INHNO_DEFINH_VALID = INHNO_VALID$
$EXCNO_DEFEXC_VALID = EXCNO_VALID$

$ 
$  チェック方法の指定
$ 
$CHECK_STKSZ_ALIGN = 8$

$ 
$  CFG_INTで使用できる割込み番号と割込み優先度
$ 
$INTNO_CFGINT_VALID = INTNO_VALID$
$INTPRI_CFGINT_VALID = RANGE(-(1 << TBITW_IPRI),-1)$

$ 
$  割込み属性中のターゲット依存に用いるビット
$ 
$ TARGET_INTATR = $
           
$ 
$  標準テンプレートファイルのインクルード
$ 
$INCLUDE "kernel/kernel.tf"$

/*$NL$
$SPC$*  Target-dependent Definitions (ARM-M)$NL$
$SPC$*/$NL$
$NL$

$ 
$  ベクターテーブル
$ 

$FILE "kernel_cfg.c"$
$NL$

extern void kernel_svc_handler(void);$NL$
$NL$

__attribute__ ((section(".vector"))) $NL$
const FP _kernel_vector_table[] =      $NL$ 
{                                    $NL$
$ 	$TAB$(FP)(TOPPERS_ISTKPT(TOPPERS_ISTK, TOPPERS_ISTKSZ)),   // 0 The initial stack pointer $NL$
	$TAB$(FP)(TOPPERS_ISTKPT(TOPPERS_STK, TOPPERS_STKSZ)),   // 0 The initial stack pointer $NL$
	$TAB$(FP)_start,                 // 1 The reset handler         $NL$

$FOREACH excno {2,3,...,14}$ 
	$IF excno == 11$
		$TAB$(FP)(kernel_svc_handler),      // 11 SVCall handler
	$ELSE$
		$TAB$(FP)(_kernel_exc_entry),
	$END$
	$SPC$$FORMAT("/* %d */", +excno)$$NL$
$END$

$FOREACH inhno INTNO_VALID$ 
	$IF LENGTH(INH.INHNO[inhno]) && (INT.INTPRI[inhno] < TIPM_LOCK)$
		$TAB$(FP)($INH.INTHDR[inhno]$),
	$ELSE$
		$TAB$(FP)(_kernel_int_entry),
	$END$
	$SPC$$FORMAT("/* %d */", +inhno)$$NL$
$END$


$NL$};$NL$
$NL$

$NL$
const FP _kernel_exc_tbl[] = $NL$
{$NL$
$FOREACH excno {0,1,...,14}$
	$IF LENGTH(EXC.EXCNO[excno])$
		$TAB$(FP)($EXC.EXCHDR[excno]$),
	$ELSE$
		$TAB$(FP)(_kernel_default_exc_handler),
	$END$
	$SPC$$FORMAT("/* %d */", +excno)$$NL$
$END$


$FOREACH inhno INTNO_VALID$
	$IF LENGTH(INH.INHNO[inhno])$
		$TAB$(FP)($INH.INTHDR[inhno]$),
	$ELSE$
		$TAB$(FP)(_kernel_default_int_handler),
	$END$
	$SPC$$FORMAT("/* %d */", +inhno)$$NL$
$END$


$NL$};$NL$
$NL$

$ 
$  _kernel_bitpat_cfgintの生成
$ 

$bitpat_cfgint_num = 0$
$bitpat_cfgint = 0$


const uint32_t _kernel_bitpat_cfgint[
$IF (TMAX_INTNO & 0x0f) == 0x00 $
	$bitpat_cfgint_num = (TMAX_INTNO >> 4)$
$ELSE$
	$bitpat_cfgint_num = (TMAX_INTNO >> 4) + 1$
$END$
	$bitpat_cfgint_num$
] = {$NL$
$FOREACH num RANGE(0,(bitpat_cfgint_num-1))$
	$bitpat_cfgint = 0$
	$FOREACH inhno RANGE(num*32, (num*32)+31)$
		$IF LENGTH(INH.INHNO[inhno])$
			$bitpat_cfgint = bitpat_cfgint | (1 << (inhno & 0x01f))$
		$END$
	$END$
	$TAB$UINT32_C($FORMAT("0x%08x", bitpat_cfgint)$), $NL$
$END$

$NL$};$NL$
$NL$
