/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010 by Meika Sugimoto
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
 */

/*
 *  プロセッサ依存モジュール アセンブリ言語部（ARM-M用）
 */

#define TOPPERS_MACRO_ONLY
#define UINT_C(val)		(val)		/* uint_t型の定数を作るマクロ */
#define ULONG_C(val)	(val)		/* ulong_t型の定数を作るマクロ */
#define CAST(type, val)	(val)		/* 型キャストを行うマクロ */

#include "kernel_impl.h"
#include "arm_m.h"


	.text

/*
 *  外部参照
 */
	.global		intnest

/*
 *  CPU例外エントリ
 *
 *  割込みエントリと処理の内容は同等だが，ログの種類が異なるため，
 *  分けている．
 */
	.align 2
	.syntax unified
	.code 16
	.global exc_entry
	.type exc_entry, function
exc_entry:
	/*
	 *  例外/割込みが発生すると，発生時にアクティブなスタックにスクラ
	 *  ッチレジスタ等が保存される．
	 *  この内容に加えて，CPU例外ハンドラへの情報として，basepri の値と，
	 *  EXC_RETURNの情報を加えて保存する．basepriの値は，CPU例外からの
	 *  リターン時に割込み優先度マスクの値を元に戻すためにも用いられる．
	 *
	 *   -----------
	 *  | EXC_RETURN|  
	 *   -----------
	 *  |  basepri  |  
	 *   -----------
	 *  |    R0     |  
	 *   -----------
	 *  |    R1     |
	 *   -----------
	 *  |    R2     |
	 *   -----------
	 *  |    R3     |
	 *   -----------
	 *  |    R12    |
	 *   -----------
	 *  |    LR     |
	 *   -----------
	 *  |    PC     |
	 *   -----------
	 *  |   xPSR    |
	 *   -----------
	 *
	 */

	/*
	 *  割込み発生時の割込み優先度マスクをスタックに保存するため取得
	 */
	mrs   r2, basepri			/* baepriの値を取得 */
	push  {r2}					/* 割込み発生時の割込み優先度マスクを積む */
	push  {lr}					/* EXC_RETURN を積む			  */ 
	mov   r0, sp				/* CPU例外ハンドラへの引数となる */
	
	ldr   r1 , =lock_flag		/* CPUロックフラグを保存 */
	ldr   r1 , [r1]
	push  {r1}
	
	/*
	 *  共通処理
	 */
exc_entry_2:
	mrs   r3, ipsr               /* ハンドラアドレスを取得 */
	ldr   r1, =_kernel_exc_tbl
	ldr   r2, [r1, r3, lsl #2]
	
#ifdef LOG_EXC_ENTER
	push  {r0, r2, r3}
	mov   r0, r3                 /* 例外番号をパラメータに  */
	bl    log_exc_enter          /* log_exc_enterを呼び出す */
	pop   {r0, r2, r3}
#endif /* LOG_EXC_ENTER */

#ifdef LOG_EXC_LEAVE
	push  { r3 }                   /* 例外番号をスタックへ    */
#endif /* LOG_EXC_LEAVE */

	/*
	 *  CPU例外ハンドラの呼び出し
	 */
	blx   r2
	
	/* CPUロックフラグを元に戻す */
	pop   {r0}
	ldr   r1 , =lock_flag
	str   r0 , [r1]
	
#ifdef LOG_EXC_LEAVE
	pop   { r0 }                   /* 例外番号を引数に        */
	bl    log_exc_leave          /* log_exc_leaveを呼び出す */
#endif /* LOG_EXC_LEAVE */
	
	b     ret_exc


/*
 *  割込みエントリ
 */
	.align 2
	.syntax unified
	.code 16
	.global int_entry
	.type int_entry, function
int_entry:
	/*
	 *	割込み発生時の割込み優先度マスクをスタックに保存するため取得
	 */
	mrs   r2, basepri			  /* baepriの値を取得 */
	push  {r2}					 /* 割込み発生時の割込み優先度マスクを積む */
	push  {lr}					 /* EXC_RETURN を積む			  */ 
	mov   r0, sp				 /* 未定義の割込みが発生した場合の情報とする */
	
	/*
	 *	共通処理
	 */
int_entry_2:
	/* 割込みネスト数の加算 */
	ldr r1 , =intnest
	ldr r3 , [r1]
	add r3 , #1
	str r3 , [r1]
	
	mrs   r3, ipsr				 /* ハンドラアドレスを取得 */
	ldr   r1, =_kernel_exc_tbl
	ldr   r2, [r1, r3, lsl #2]

#ifdef LOG_INH_ENTER
	push  {r0,r2,r3}
	mov   r0, r3                 /* 例外番号をパラメータに  */
	bl    log_inh_enter          /* log_exc_enterを呼び出す */
	pop   { r0,r2,r3 }
	push  { r3 }                   /* 例外番号をスタックへ    */
#endif /* LOG_INH_ENTER */

#ifdef LOG_INH_LEAVE
	push  { r3 }                   /* 例外番号をスタックへ    */
#endif /* LOG_INT_LEAVE */

	/*
	 *  CPU例外ハンドラの呼び出し
	 */
	blx   r2
	
#ifdef LOG_INH_LEAVE
	pop   { r0 }                   /* 例外番号を引数に        */
	bl    log_inh_leave          /* log_exc_leaveを呼び出す */
#endif /* LOG_INH_LEAVE */

/*
 *  割込み/例外出口
 *
 *  ret_exc/ret_intは，CPU例外/割込みハンドラから戻った直後に実行する
 *  ルーチンである．
 */
ret_exc:
ret_int:
	/*
	 *  割込みロック状態とする．この時点では，CPUロック状態にはならない
	 * （basepriとlock_flagとsaved_iipmは更新しない）．
	 *
	 *  割込みロック状態とするのは，戻り先のコンテキストのチェックと，
	 *  戻り先が非タスクコンテキストであった場合のリターンをアトミック
	 *  に行うためである．bsepriをCPUロックの値にすることでもアトミッ
	 *  クなチェックと復帰は可能であるが，割込みからリターンしても，
	 *  basepri の設定内容は元に戻らないため，使用することができない． 
	 *  一方，FAULTMASKは，割込みからのリターン処理によって，'0'にクリ
	 *  アされる．
	 */
	cpsid f
	
	/*
	 *  戻り先のコンテキストの判定
	 * 
	 *  intnestが0かどうかで判断する
	 *  
	 */
	/* 割込みネスト数の減算 */
	ldr r1 , =intnest
	ldr r3 , [r1]
	add r3 , #-1
	str r3 , [r1]
	
	cmp   r3 , #0
	beq   ret_int_2
	
	/*
	 *  一段目の割込みの出口処理
	 */
ret_int_1:
	/*
	 *  ここには割込みロック状態（FAULTMASKがセット）された状態で来る．
	 *  Threadモードからのリターンにより自動的に割込みロック解除状態になる．
	 *  割込み優先度マスクは割込み前に状態に戻す．
	 */ 
	pop		{ r2 }
	pop		{ r1 }
	msr   basepri, r1			  /* 割込み優先度マスクを割込み前に状態へ */
	bx	  r2					  /* リターン */
	
ret_int_2:
	ldr   r0, =reqflg             /* reqflgがfalseならそのまま戻る */
	ldr   r1, [r0]
	cmp   r1 , #0
	beq    ret_int_1           /* falseならret_int_1へ           */
ret_int_3:
	mov   r1, #0                   /* reqflgをfalseに */
	str   r1, [r0]
	
	/*
	 *  CPUロック状態に移行する．
	 *
	 *  カーネルの管理内の割込みを禁止するようにbasepriを設定し，
	 *  lock_flagを更新する．
	 *  この時点でCPUロック状態とするのは，dispatcherへ分岐する時に
	 *  CPUロック状態になっている必要があるためである．
     *  なお，この処理の後，Threadモードへの移行処理を行なうため，割込み
     *  ロック状態(FAULTMASKを"1")は保持する．
	 */
	ldr   r1, =IIPM_LOCK		  /* CPUロック状態 */ 
	msr   basepri, r1
	mov   r1, #0x01 			  /* lock_flag を trueに */
	ldr   r0, =lock_flag 
	str   r1, [r0]
	
	/*
	 *  lrを取り出す．ただし遅延ディスパッチの際にも使うため，
	 *  スタックポインタは操作しない．
	 */
	
	ldr   r2 , [sp]
	
	/*
	 *  Threadモードへ移行する．
	 *
	 *  dispatcherやcall_texrnを呼び出す場合は，Threadモードである必
	 *  要があるため，PSPスタック上にダミーの例外フレームを置いて，
	 *  擬似的に割込みハンドラからリターンする．
	 *  リターンと同時にFAULTMASKが自動的にクリアされ，カーネル管理外の
	 *  割込みが許可される．
	 */
	ldr   r0, =ret_int_4		  /* PC   */
	ldr   r1, =EPSR_T			  /* xPSR(Tビットが'1'である必要がある) */
	stmfd sp!, {r0-r1}			  /* ダミーフレームをスタック上に積む	*/
	sub   sp, #(EXC_FRAME_SIZE - (4*2)) /* r0-r3,r12,lrの内容は設定する必要がない */
	bx	  r2					  /* Threadモードへ移行 */
    
ret_int_4:
	bl    search_schedtsk		/* 割込み中で起動されたタスクを実行 */
	bl    run_task
ret_int_r:
	svc   0 				   /* SVCの呼び出し */
	
/*
 *  遅延ディスパッチからの復帰時に一時的に割込み
 *  コンテキストに移行するためのSVCコールハンドラ
 */

	.align	2
	.thumb
	.thumb_func
	.globl kernel_svc_handler
kernel_svc_handler:
	/*
	 *  割込み処理からのリターンにより，CPUロック解除状態に移行するよ
	 *  う準備する．
	 */
	cpsid f 								/* 割込みロック状態へ */
	ldr		r2 , [ sp , #(EXC_FRAME_SIZE) ]	/* lrをスタックから取得	*/
	add		sp, #EXC_FRAME_SIZE + 8			/* スタックを捨てる	*/
	mov		r0, #0
	ldr		r1, =lock_flag					/* CPUロック解除状態へ */
	str		r0, [r1]
	msr		basepri , r0 
	bx		r2								/* リターン	  */

/*
 *  ディスパッチャの動作開始
 */
	.align	2
	.thumb
	.thumb_func
	.globl start_dispatch
start_dispatch:
	/*
	 *  このルーチンは，カーネル起動時に，すべての割込みを禁止した状態
	 * （割込みロック状態と同等）で呼び出される．また，割込みモード（非
	 *  タスクコンテキストと同等）で呼び出されることを想定している．
	 *
	 *  prc_initializeで，lock_flagをtrueに，saved_iipmをIIPM_ENAALLに
	 *  初期化しているため，カーネル管理外の割込みを許可することで，
	 *  CPUロック状態・（モデル上の）割込み優先度マスク全解除状態になる．
	 *  また，task_initializeでdisdspをfalseに初期化しているため，ディ
	 *  スパッチ許可状態になっている．
	 */
	ldr   r0,=istkpt              /* MSPを初期化   */
	ldr   r1,[r0]                 /* start_dispatch呼び出し時に呼び出し用に */
	msr   msp, r1                 /* 使用しているため初期化する             */
	ldr   r1, =IIPM_LOCK          /* カーネル管理内の割込みを禁止 */
	msr   basepri, r1 
	cpsie f                       /* カーネル管理外の割込みを許可 */
	b	  dispatcher

/*
 *  カーネルの終了処理の呼出し
 *
 *  スタックを非タスクコンテキスト用に切り替え．
 *  
 */
	.text
	.syntax unified
	.code 16
	.globl call_exit_kernel
	.type call_exit_kernel, function
call_exit_kernel:
	b     exit_kernel       /* カーネルの終了処理を呼ぶ */


/*
 *  微少時間待ち
 */
	.text
	.syntax unified
	.code 16
	.globl sil_dly_nse
	.type sil_dly_nse, function
sil_dly_nse:
	sub   r0, r0, #SIL_DLY_TIM1
	cmp   r0, #0
	bgt   sil_dly_nse1
	mov   pc, lr
sil_dly_nse1:
	sub   r0, r0, #SIL_DLY_TIM2
	cmp   r0, #0
	bgt   sil_dly_nse1
	mov   pc, lr
