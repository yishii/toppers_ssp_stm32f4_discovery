/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 * 
 *  上記著作権者は，以下の(1)〜(4)の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改
 *  変・再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作
 *      権表示，この利用条件および下記の無保証規定が，そのままの形でソー
 *      スコード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使
 *      用できる形で再配布する場合には，再配布に伴うドキュメント（利用
 *      者マニュアルなど）に，上記の著作権表示，この利用条件および下記
 *      の無保証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使
 *      用できない形で再配布する場合には，次のいずれかの条件を満たすこ
 *      と．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著
 *        作権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに
 *        報告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損
 *      害からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 *      また，本ソフトウェアのユーザまたはエンドユーザからのいかなる理
 *      由に基づく請求からも，上記著作権者およびTOPPERSプロジェクトを
 *      免責すること．
 * 
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者お
 *  よびTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的
 *  に対する適合性も含めて，いかなる保証も行わない．また，本ソフトウェ
 *  アの利用により直接的または間接的に生じたいかなる損害に関しても，そ
 *  の責任を負わない．
 * 
 *  @(#) $Id: prc_config.h 1304 2008-08-27 07:28:36Z ertl-honda $
 */

/*
 *		プロセッサ依存モジュール（ARM-M用）
 *
 *  このインクルードファイルは，target_config.h（または，そこからインク
 *  ルードされるファイル）のみからインクルードされる．他のファイルから
 *  直接インクルードしてはならない．
 */

#ifndef TOPPERS_PRC_CONFIG_H
#define TOPPERS_PRC_CONFIG_H

#ifndef TOPPERS_MACRO_ONLY

/*
 *  プロセッサの特殊命令のインライン関数定義
 */
#include "prc_insn.h"

/*
 *  非タスクコンテキスト用のスタック初期値
 */
#define TOPPERS_ISTKPT(istk, istksz) ((STK_T *)((istk) + (istksz)))

#endif /* TOPPERS_MACRO_ONLY */

#ifndef TOPPERS_MACRO_ONLY

/*
 *  割込みネスト数
 */
extern uint8_t intnest;

/*
 *  コンテキストの参照
 *
 */
Inline bool_t
sense_context(void)
{
	bool_t tskctx;
	
	if (intnest == 0u){
		tskctx = false;
	}
	else {
		tskctx = true;
	}
	
	return tskctx;
}

#endif /* TOPPERS_MACRO_ONLY */

/*
 *  TOPPERS標準割込み処理モデルの実現
 *
 *  割込み優先度マスクとしては，BASEPRIを用いる．全割込みを禁止する
 *  機能として，FAULTMASKやPRIMASKがあるが，カーネル管理外の割込みを
 *  サポートするため，これらはCPUロックのために用いない．
 *  そのため，BASEPRIを用いて擬似的にCPUロックフラグを実現する．
 *
 *  まず，CPUロック状態を管理すための変数(lock_flag)を用意する．
 *
 *  CPUロックフラグがクリアされている間は，BASEPRIをモデル上の割込み
 *  優先度マスクの値に設定する．この間は，モデル上の割込み優先度マス
 *  クは，BASEPRIを用いる．
 * 
 *  それに対してCPUロックフラグがセットされいる間は，BASEPRIを，カーネ
 *  ル管理外のものを除くすべての割込み要求をマスクする値(TIPM_LOCK)と，
 *  モデル上の割込み優先度マスクとの高い方に設定する．この間のモデル上
 *  の割込み優先度マスクは，そのための変数(saved_iipm, 内部表現で保持)
 *  を用意して保持する．
 */

/*
 *  割込み優先度マスクの外部表現と内部表現の変換
 *
 *  アセンブリ言語のソースファイルからインクルードする場合のために，
 *  CASTを使用
 *  割込み優先度のビット幅(TBITW_IPRI)が 8 の場合は，内部優先度 255
 *  は，外部優先度 -1 に対応する．
 */
#define EXT_IPM(iipm)   (CAST(PRI,((iipm >> (8 - TBITW_IPRI)) - (1 << TBITW_IPRI))))       /* 内部表現を外部表現に */
#define INT_IPM(ipm)    (((1 << TBITW_IPRI) - CAST(uint8_t, -(ipm)))  << (8 - TBITW_IPRI)) /* 外部表現を内部表現に */

/*
 *  CPUロック状態での割込み優先度マスク
 */
#define TIPM_LOCK    TMIN_INTPRI

/*
 *  CPUロック状態での割込み優先度マスクの内部表現
 *
 *  TIPM_LOCKは，CPUロック状態でのBASEPRIの値．カーネル管理外のものを
 *  除くすべての割込みをマスクする値に定義する．  
 */
#define IIPM_LOCK    INT_IPM(TIPM_LOCK)

/*
 *  TIPM_ENAALL（割込み優先度マスク全解除）の内部表現
 *
 *  BASEPRIに '0' を設定することで，全割込みを許可する．
 */
#define IIPM_ENAALL  (0)


#ifndef TOPPERS_MACRO_ONLY

/*
 *  CPUロックフラグ実現のための変数
 * 
 *  これらの変数は，CPUロック状態の時のみ書き換えてもよいとする．
 *  インライン関数中で，アクセスの順序が変化しないよう，volatile を指定． 
 */
extern volatile bool_t  lock_flag;    /* CPUロックフラグの値を保持する変数 */
extern volatile uint32_t saved_iipm;  /* 割込み優先度をマスクする変数 */

/*
 *  CPUロック状態への移行
 *
 *  BASEPRI（ハードウェアの割込み優先度マスク）を，saved_iipmに保存し，
 *  カーネル管理外のものを除くすべての割込みをマスクする値（TIPM_LOCK）
 *  に設定する．また，lock_flagをtrueにする．
 *
 *  BASEPRIが，最初からTIPM_LOCKと同じかそれより高い場合には，それを
 *  saved_iipmに保存するのみで，TIPM_LOCKには設定しない．これは，モデル
 *  上の割込み優先度マスクが，TIPM_LOCKと同じかそれより高いレベルに設定
 *  されている状態にあたる．
 *
 *  この関数は，CPUロック状態（lock_flagがtrueの状態）で呼ばれることは
 *  ないものと想定している．
 */
Inline void
x_lock_cpu(void)
{
	uint32_t iipm;

	/*
	 *  current_iipm()の返り値を直接saved_iipmに保存せず，一時変数iipm
	 *  を用いているのは，current_iipm()を呼んだ直後に割込みが発生し，
	 *  起動された割込み処理でsaved_iipmが変更される可能性があるためで
	 *  ある．
	 */
	iipm = get_basepri();
	set_basepri(IIPM_LOCK);
	saved_iipm = iipm;
	lock_flag = true;
	/* クリティカルセクションの前後でメモリが書き換わる可能性がある */
	Asm("":::"memory");
}

#define t_lock_cpu()    x_lock_cpu()
#define i_lock_cpu()    x_lock_cpu()

/*
 *  CPUロック状態の解除
 *
 *  lock_flagをfalseにし，IPM（ハードウェアの割込み優先度マスク）を，
 *  saved_iipmに保存した値に戻す．
 *
 *  この関数は，CPUロック状態（lock_flagがtrueの状態）でのみ呼ばれるも
 *  のと想定している．
 */
Inline void
x_unlock_cpu(void)
{
	/* クリティカルセクションの前後でメモリが書き換わる可能性がある */
	Asm("":::"memory");
	lock_flag = false;
	set_basepri(saved_iipm);
}

#define t_unlock_cpu()    x_unlock_cpu()
#define i_unlock_cpu()    x_unlock_cpu()

/*
 *  CPUロック状態の参照
 */
Inline bool_t
x_sense_lock(void)
{
	return(lock_flag);
}

#define t_sense_lock()    x_sense_lock()
#define i_sense_lock()    x_sense_lock()


/*
 * （モデル上の）割込み優先度マスクの設定
 *
 *  CPUロックフラグがクリアされている時は，ハードウェアの割込み優先度マ
 *  スクを設定する．CPUロックフラグがセットされている時は，saved_iipm
 *  を設定し，さらに，ハードウェアの割込み優先度マスクを，設定しようと
 *  した（モデル上の）割込み優先度マスクとTIPM_LOCKの高い方に設定する．
 */
Inline void
x_set_ipm(PRI intpri)
{
	uint8_t   iipm = INT_IPM(intpri);

	if (intpri == TIPM_ENAALL){
		iipm = IIPM_ENAALL;
	}

	if (!lock_flag) {
		set_basepri(iipm);
	}
	else {
		saved_iipm = iipm;
		set_basepri(iipm < IIPM_LOCK ? iipm : IIPM_LOCK);
	}
}

#define t_set_ipm(intpri)    x_set_ipm(intpri)
#define i_set_ipm(intpri)    x_set_ipm(intpri)

/*
 * （モデル上の）割込み優先度マスクの参照
 *
 *  CPUロックフラグがクリアされている時はハードウェアの割込み優先度マ
 *  スクを，セットされている時はsaved_iipmを参照する．
 */
Inline PRI
x_get_ipm(void)
{
	uint8_t iipm;

	if (!lock_flag) {
		iipm = get_basepri();
	}
	else {
		iipm = saved_iipm;
	}

	if (iipm == IIPM_ENAALL) {
		return(TIPM_ENAALL);
	}
	else {
		return(EXT_IPM(iipm));
	}
}

#define t_get_ipm()    x_get_ipm()
#define i_get_ipm()    x_get_ipm()

/*
 *  SVCハンドラ（prc_support.S）
 */
extern void svc_handler(void);

/*
 *  スタートアップルーチン（start.S）
 */
extern void _start(void);

/*
 *  ディスパッチャの動作開始（prc_support.S）
 *
 *  start_dispatchは，カーネル起動時に呼び出すべきもので，すべての割込
 *  みを禁止した状態（割込みロック状態と同等の状態）で呼び出さなければ
 *  ならない．
 */
extern void start_dispatch(void) NoReturn;


/*
 *  カーネルの終了処理の呼出し（prc_support.S）
 *
 *  call_exit_kernelは，カーネルの終了時に呼び出すべきもので，非タスク
 *  コンテキストに切り換えて，カーネルの終了処理（exit_kernel）を呼び出
 *  す．
 */
extern void call_exit_kernel(void) NoReturn;

/*
 *  アイドルループの実装
 *
 *  単にCPUロック状態とCPUロック解除状態を呼び出す実装とする．
 *  スリープモードに入れる場合は本処理をwfi命令を用いて書き換えれば良い．
 */
Inline void
idle_loop(void)
{
	lock_flag = false;
	/* CPUアンロック => CPUロック  */
	Asm("\tmsr BASEPRI , %0" : : "r"(0) : "memory");
	Asm("\tmsr BASEPRI , %0" : : "r"(IIPM_LOCK) : "memory");
	lock_flag = true;
}

/*
 *  割込み番号・割込みハンドラ番号
 *
 *  割込みハンドラ番号(inhno)と割込み番号(intno)は，割り込み発生時に
 *  EPSRに設定される例外番号とする． 
 */

/*
 *  割込み番号の範囲の判定
 */
#define VALID_INTNO(intno)           ((TMIN_INTNO <= (intno)) && ((intno) <= TMAX_INTNO))
#define VALID_INTNO_DISINT(intno)    VALID_INTNO(intno)
#define VALID_INTNO_CFGINT(intno)    VALID_INTNO(intno)

/*
 *  割込みハンドラの設定
 *
 *  ベクトル番号inhnoの割込みハンドラの起動番地int_entryに設定する．割込み
 *  ハンドラテーブル
 */
Inline void
x_define_inh(INHNO inhno, FP int_entry)
{
	/* 特に行う処理はない */
}

/*
 *  割込みハンドラの出入口処理の生成マクロ
 *
 */
#define INT_ENTRY(inhno, inthdr)    inthdr
#define INTHDR_ENTRY(inhno, inhno_num, inthdr) extern void inthdr(void);

/*
 *  割込み要求禁止フラグ
 */

/*
 *  割込み属性が設定されているかを判別するための変数（kernel_cfg.c）
 */
extern const uint32_t	bitpat_cfgint[];

/*
 *  割込み要求禁止フラグのセット
 *
 *  割込み属性が設定されていない割込み要求ラインに対して割込み要求禁止
 *  フラグをクリアしようとした場合には，falseを返す．  
 */
Inline bool_t
x_disable_int(INTNO intno)
{
	uint32_t tmp;

	/*
	 *  割込み属性が設定されていない場合
	 */
	if ((bitpat_cfgint[intno >> 5] & (1 << (intno & 0x1f))) == 0x00) {
		return(false);
	}

	if (intno == IRQNO_SYSTICK) {
		tmp = sil_rew_mem((void *)SYSTIC_CONTROL_STATUS);
		tmp &= ~SYSTIC_TICINT;
		sil_wrw_mem((void *)SYSTIC_CONTROL_STATUS, tmp);
	}else {
		tmp = intno - 16;
		sil_wrw_mem((void *)NVIC_CLRENA0 + (tmp >> 5), (1 << (tmp & 0x1f)));
	}

	return(true);
}

#define t_disable_int(intno) x_disable_int(intno)
#define i_disable_int(intno) x_disable_int(intno)

/*
 *  割込み要求禁止フラグの解除
 *
 *  割込み属性が設定されていない割込み要求ラインに対して割込み要求禁止
 *  フラグをクリアしようとした場合には，falseを返す．
 */
Inline bool_t
x_enable_int(INTNO intno)
{
	uint32_t tmp;

	/*
	 *  割込み属性が設定されていない場合
	 */
	if ((bitpat_cfgint[intno >> 5] & (1 << (intno & 0x1f))) == 0x00) {
		return(false);
	}

	if (intno == IRQNO_SYSTICK) {
		tmp = sil_rew_mem((void *)SYSTIC_CONTROL_STATUS);
		tmp |= SYSTIC_TICINT;
		sil_wrw_mem((void *)SYSTIC_CONTROL_STATUS, tmp);
	}else {
		tmp = intno - 16;
		sil_wrw_mem((void *)((uint32_t *)NVIC_SETENA0 + (tmp >> 5)),
					(1 << (tmp & 0x1f)));
	}
    
	return(true);
}

#define t_enable_int(intno) x_enable_int(intno)
#define i_enable_int(intno) x_enable_int(intno)

Inline void
x_clear_int(INTNO intno)
{
	uint32_t tmp;
	
	if (intno != IRQNO_SYSTICK) {
		tmp = intno - 16;
		sil_wrw_mem((void *)((uint32_t *)NVIC_CLRENA0 + (tmp >> 5)),
					(1 << (tmp & 0x1f)));
	}
}

/*
 *  割込み要求ラインの属性の設定
 */
extern void x_config_int(INTNO intno, ATR intatr, PRI intpri);

/*
 *  割込みハンドラ入口で必要なIRC操作
 */
Inline void
i_begin_int(INTNO intno)
{
	/* 特に行う処理はない */
}

/*
 *  割込みハンドラの出口で必要なIRC操作
 */
Inline void
i_end_int(INTNO intno)
{
	/* 特に行う処理はない */
}

/*
 *  CPU例外ハンドラ関係
 */ 

/*
 *  CPU例外ハンドラ番号
 */
#define VALID_EXCNO_DEFEXC(excno)    (TMIN_EXCNO <= (excno) && (excno) <= TMAX_EXCNO)

/*
 *  CPU例外ハンドラの許可
 */
extern void enable_exc(EXCNO excno);

/*
 *  CPU例外ハンドラの禁止
 */
extern void disable_exc(EXCNO excno);

/*
 *  CPU例外ハンドラの設定
 */
Inline void
x_define_exc(EXCNO excno, FP exc_entry)
{
	/*
	 *  一部の例外は許可を行う必要がある
	 */
	enable_exc(excno);
}

/*
 *  CPU例外ハンドラの入口処理の生成マクロ
 */
#define EXC_ENTRY(excno, exchdr)    exchdr
#define EXCHDR_ENTRY(excno, excno_num, exchdr) extern void exchdr(void *p_excinf);


/*
 *  CPU例外エントリ（prc_support.S）
 */
extern void exc_entry(void);

/*
 *  割込みエントリ（prc_support.S）
 */
extern void int_entry(void);

/*
 *  プロセッサ依存の初期化
 */
extern void prc_initialize(void);

/*
 *  プロセッサ依存の終了時処理
 */
extern void prc_terminate(void);

/*
 *  atexitの処理とデストラクタの実行
 */
Inline void
call_atexit(void)
{
	extern void    software_term_hook(void);
	void (*volatile fp)(void) = software_term_hook;

	/*
	 *  software_term_hookへのポインタを，一旦volatile指定のあるfpに代
	 *  入してから使うのは，0との比較が最適化で削除されないようにするた
	 *  めである．
	 */
	if (fp != 0) {
		(*fp)();
	}
}

/*
 * 登録されていない例外が発生すると呼び出される
 */
extern void default_exc_handler(void *p_excinf);

/*
 * 未登録の割込みが発生した場合に呼び出される
 */
extern void default_int_handler(void *p_excinf);

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_PRC_CONFIG_H */
