/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 *
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2009 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010 by Naoki Saito
 *             Nagoya Municipal Industrial Research Institute, JAPAN
 *  Copyright (C) 2011 by Meika Sugimoto
 * 
 *  上記著作権者は，以下の (1)〜(4) の条件を満たす場合に限り，本ソフトウェ
 *  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改変・
 *  再配布（以下，利用と呼ぶ）することを無償で許諾する．
 *  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作権
 *      表示，この利用条件および下記の無保証規定が，そのままの形でソース
 *      コード中に含まれていること．
 *  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使用
 *      できる形で再配布する場合には，再配布に伴うドキュメント（利用者マ
 *      ニュアルなど）に，上記の著作権表示，この利用条件および下記の無保
 *      証規定を掲載すること．
 *  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使用
 *      できない形で再配布する場合には，次のいずれかの条件を満たすこと．
 *    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著作
 *        権表示，この利用条件および下記の無保証規定を掲載すること．
 *    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに報
 *        告すること．
 *  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損害
 *      からも，上記著作権者およびTOPPERSプロジェクトを免責すること．また，
 *      本ソフトウェアのユーザまたはエンドユーザからのいかなる理由に基づ
 *      く請求からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
 * 
 *  本ソフトウェアは，無保証で提供されているものである．上記著作権者およ
 *  びTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的に対す
 *  る適合性も含めて，いかなる保証も行わない．また，本ソフトウェアの利用
 *  により直接的または間接的に生じたいかなる損害に関しても，その責任を負
 *  わない．
 * 
 */

#ifndef TOPPERS_TASK_H
#define TOPPERS_TASK_H

#include "kernel_impl.h"


/*
 *  タスク優先度の内部表現・外部表現変換マクロ
 */
#define INT_PRIORITY(x)		((uint_t)((x) - TMIN_TPRI))

/*
 *  タスクIDの最大値（kernel_cfg.c）
 */
extern const ID	tmax_tskid;

/*
 *  タスクの数
 */
#define tnum_tsk	((uint_t)(tmax_tskid - TMIN_TSKID + 1))

/*
 *  実行可能状態のタスクがない時に実行中タスクの現在優先度に設定する値
 */
#define TSKPRI_NULL		(UINT_MAX)


/*
 *  レディキューサーチのためのビットマップ
 */
extern volatile uint_t	ready_primap;

/*
 *  ディスパッチ／タスク例外処理ルーチン起動要求フラグ
 *
 *  割込みハンドラ／CPU例外ハンドラの出口処理に，ディスパッチまたは
 *  タスク例外処理ルーチンの起動を要求することを示すフラグ．
 */
extern bool_t	reqflg;

/*
 *  ディスパッチ禁止状態
 *
 *  ディスパッチ禁止状態であることを示すフラグ．
 */
extern bool_t	disdsp;

/*
 *  実行状態タスクの現在優先度
 *
 *  実行中のタスクに実行時優先度が設定されていれば実行時優先度が，
 *  設定されていなければ起動時優先度が設定される．
 */
extern uint_t runtsk_curpri;

/*
 *  実行状態タスクの起動時優先度
 */
extern uint_t runtsk_ipri;

/*
 *  タスク管理モジュールの初期化
 *
 *  全てのタスクを初期化する．各タスクはタスク属性にTA_ACTが設定されていれば
 *  実行可能状態，そうでない場合は休止状態となる．
 *  
 *  また、ディスパッチ許可フラグをディスパッチ許可状態に設定する．
 *  
 *  本関数はコンフィギュレータが生成するobject_initialize以外で呼んではならない．
 */
extern void initialize_task(void);

/*
 *  タスクの起動
 *
 *  ipriで指定した起動時優先度を持つタスクを実行可能状態に遷移させる．
 *  本関数を実行することによりプリエンプトが発生する場合はtrueを，
 *  そうでない場合はfalseを返す．
 *
 *  本関数はCPUロック状態，全割込みロック解除状態，割込み優先度マスク全解除状態で
 *  呼び出すこと．
 */
extern bool_t make_active(uint_t ipri);

/*
 *  指定した起動時優先度のタスクが休止状態かどうかのテスト
 *
 *  ipriで指定した起動時優先度を持つタスクが休止状態であれば
 *  trueをそれ以外（実行可能状態，実行可能状態）であればfalseを返す．
 *
 *  本関数はCPUロック状態，全割込みロック解除状態，割込み優先度マスク全解除状態で
 *  呼び出すこと．
 */
extern bool_t test_dormant(uint_t ipri);

/*
 *  最高優先順位タスクのサーチ
 *
 *  実行可能状態のタスクの中から最も優先順位が高いタスクの初期優先度を
 *  返す．
 *
 *  本関数はCPUロック状態，全割込みロック解除状態，割込み優先度マスク全解除状態で
 *  呼び出すこと．
 */
extern uint_t search_schedtsk(void);

/*
 *  タスクの実行
 *
 *  ipriで指定した起動時優先度を持つタスクを実行する．
 *  本関数から実行したタスクからサービスコールを経由して
 *  再帰的に呼ばれることもある．
 *
 *  本関数はCPUロック状態，全割込みロック解除状態，割込み優先度マスク全解除状態で
 *  呼び出すこと．
 */
extern void run_task(uint_t ipri);

/*
 *  タスクディスパッチャ
 *
 *  カーネル初期化完了後に呼び出され，最高優先順位となったタスクを実行する．
 *
 *  本関数はCPUロック状態，全割込みロック解除状態，割込み優先度マスク全解除状態で
 *  呼び出すこと．
 *  なお，本関数からはリターンしない．
 *  
 */
extern void dispatcher(void) NoReturn;

/*
 *  タスクの起動時優先度取得(タスクコンテキスト用)
 *
 *  tskidで指定したタスクの起動時優先度を取得する．
 *  tskidはTMIN_TSKID以上，tmax_tskid以下の値，もしくはTSK_SELFで
 *  指定しなければならない．
 */
extern uint_t get_ipri_self(ID tskid);

/*
 *  タスクの起動時優先度取得(非タスクコンテキスト用)
 *
 *  tskidで指定したタスクの起動時優先度を取得する．
 *  tskidはTMIN_TSKID以上，tmax_tskid以下の値で指定しなければならない．
 */
extern uint_t get_ipri(ID tskid);

#endif /* TOPPERS_TASK_H */
