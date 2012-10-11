$ ======================================================================
$ 
$  TOPPERS/SSP Kernel
$      Smallest Set Profile Kernel
$ 
$   Copyright (C) 2007 by TAKAGI Nobuhisa
$   Copyright (C) 2007-2009 by Embedded and Real-Time Systems Laboratory
$               Graduate School of Information Science, Nagoya Univ., JAPAN
$   Copyright (C) 2010-2012 by Naoki Saito
$               Nagoya Municipal Industrial Research Institute, JAPAN
$ 
$  上記著作権者は，以下の (1)〜(4) の条件を満たす場合に限り，本ソフトウェ
$  ア（本ソフトウェアを改変したものを含む．以下同じ）を使用・複製・改変・
$  再配布（以下，利用と呼ぶ）することを無償で許諾する．
$  (1) 本ソフトウェアをソースコードの形で利用する場合には，上記の著作権
$      表示，この利用条件および下記の無保証規定が，そのままの形でソース
$      コード中に含まれていること．
$  (2) 本ソフトウェアを，ライブラリ形式など，他のソフトウェア開発に使用
$      できる形で再配布する場合には，再配布に伴うドキュメント（利用者マ
$      ニュアルなど）に，上記の著作権表示，この利用条件および下記の無保
$      証規定を掲載すること．
$  (3) 本ソフトウェアを，機器に組み込むなど，他のソフトウェア開発に使用
$      できない形で再配布する場合には，次のいずれかの条件を満たすこと．
$    (a) 再配布に伴うドキュメント（利用者マニュアルなど）に，上記の著作
$        権表示，この利用条件および下記の無保証規定を掲載すること．
$    (b) 再配布の形態を，別に定める方法によって，TOPPERSプロジェクトに報
$        告すること．
$  (4) 本ソフトウェアの利用により直接的または間接的に生じるいかなる損害
$      からも，上記著作権者およびTOPPERSプロジェクトを免責すること．また，
$      本ソフトウェアのユーザまたはエンドユーザからのいかなる理由に基づ
$      く請求からも，上記著作権者およびTOPPERSプロジェクトを免責すること．
$ 
$  本ソフトウェアは，無保証で提供されているものである．上記著作権者およ
$  びTOPPERSプロジェクトは，本ソフトウェアに関して，特定の使用目的に対す
$  る適合性も含めて，いかなる保証も行わない．また，本ソフトウェアの利用
$  により直接的または間接的に生じたいかなる損害に関しても，その責任を負
$  わない．
$ 
$ ======================================================================

$ ログ出力
$   指定した数だけ行頭にタブをつけて表示する．
$   コード及び出力の可読性を挙げるために使う．
$     引数 : ARGV[1] : 行頭に挿入するタブの数
$     返値 : 空文字列
$     注意 : RESULTを操作しているため，他の関数の出力を保存する前に呼び出すと上書きされる．
$ 
$FUNCTION LOG$
	$FOREACH i RANGE(1,ARGV[1])$$TAB$$END$
	$RESULT = {}$
$END$

$ =====================================================================
$ 処理前のチェック
$ =====================================================================

$ タスクが1個以上存在することのチェック
$IF !LENGTH(TSK.ID_LIST)$
	$ERROR$$FORMAT("no task is registered")$$END$
$END$

$ =====================================================================
$ kernel_cfg.h の生成
$ =====================================================================

$FILE "kernel_cfg.h"$

/* kernel_cfg.h */$NL$
#ifndef TOPPERS_KERNEL_CFG_H$NL$
#define TOPPERS_KERNEL_CFG_H$NL$
$NL$
#define TNUM_TSKID	$LENGTH(TSK.ID_LIST)$$NL$
#define TNUM_CYCID	$LENGTH(CYC.ORDER_LIST)$$NL$
#define TNUM_ALMID	$LENGTH(ALM.ORDER_LIST)$$NL$
$NL$

$ // タスクIDを起動優先度(tskapri)の高い順に reallocate_tskapri へ割り当て，
$ // 定義を kernel_cfg.h へ出力する．
$tsk_apriorder_list={}$
$tsk_epri_list={}$
$tsk_index = 1$
$FOREACH id SORT(TSK.ORDER_LIST, "TSK.ATSKPRI")$
	$tsk_apriorder_list = APPEND(tsk_apriorder_list, TSK.TSKID[id])$
	$reallocate_tskapri[TSK.TSKID[id]] = tsk_index$
	#define $TSK.TSKID[id]$	$tsk_index$$NL$

$	DEF_EPRI で定義されていないタスクの実行時優先度が，起動優先度と同じになるようにする．
	$tsk_epri_list = APPEND(tsk_epri_list, ALT(TSK.ETSKPRI[TSK.TSKID[id]], TSK.ATSKPRI[TSK.TSKID[id]]))$
	$tsk_index = tsk_index + 1$
$END$
$FOREACH id CYC.ID_LIST$
	#define $id$	$+id$$NL$
$END$
$FOREACH id ALM.ID_LIST$
	#define $id$	$+id$$NL$
$END$

#endif /* TOPPERS_KERNEL_CFG_H */$NL$

$ =====================================================================
$ kernel_cfg.cの生成
$ =====================================================================

$FILE "kernel_cfg.c"$

/* kernel_cfg.c */$NL$
#include "kernel/kernel_int.h"$NL$
#include "kernel_cfg.h"$NL$
$NL$
#ifndef TOPPERS_EMPTY_LABEL$NL$
#define TOPPERS_EMPTY_LABEL(x,y) x y[0]$NL$
#endif$NL$
$NL$

$ ---------------------------------------------------------------------
$  インクルードディレクティブ（#include）
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Include Directives (#include)$NL$
$SPC$*/$NL$
$NL$
$INCLUDES$
$NL$

$ ---------------------------------------------------------------------
$  オブジェクトのID番号を保持する変数
$ ---------------------------------------------------------------------
$IF USE_EXTERNAL_ID$
	/*$NL$
	$SPC$*  Variables for Object ID$NL$
	$SPC$*/$NL$
	$NL$
	$FOREACH id TSK.ID_LIST$
		const ID $id$_id$SPC$=$SPC$$+id$;$NL$
	$END$
	$FOREACH id CYC.ID_LIST$
		const ID $id$_id$SPC$=$SPC$$+id$;$NL$
	$END$
	$FOREACH id ALM.ID_LIST$
		const ID $id$_id$SPC$=$SPC$$+id$;$NL$
	$END$
$END$

$ ---------------------------------------------------------------------
$  トレースログマクロのデフォルト定義
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Default Definitions of Trace Log Macros$NL$
$SPC$*/$NL$
$NL$
#ifndef LOG_ISR_ENTER$NL$
#define LOG_ISR_ENTER(intno)$NL$
#endif /* LOG_ISR_ENTER */$NL$
$NL$
#ifndef LOG_ISR_LEAVE$NL$
#define LOG_ISR_LEAVE(intno)$NL$
#endif /* LOG_ISR_LEAVE */$NL$
$NL$


$ ---------------------------------------------------------------------
$  タスクに関する出力
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Task Management Functions$NL$
$SPC$*/$NL$
$NL$

$ タスクID番号の最大値
const ID _kernel_tmax_tskid = (TMIN_TSKID + TNUM_TSKID - 1);$NL$
$NL$

$ ready_primap の初期値
$init_rdypmap = 0$
$tsk_index = 1$

$ タスク属性．
const ATR     	_kernel_tinib_tskatr[TNUM_TSKID]    = {
$JOINEACH tskid tsk_apriorder_list ","$
$	// TA_ACT , TA_RSTR または TA_NULL である（E_RSATR）
	$IF (TSK.TSKATR[tskid] & ~(TA_ACT | TA_RSTR | ALT(TARGET_TSKATR,0))) != 0$
		$ERROR TSK.TEXT_LINE[tskid]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "tskatr", TSK.TSKATR[tskid], tskid, "CRE_TSK")$$END$
	$END$

	($TSK.TSKATR[tskid]$)
	
	$IF TSK.TSKATR[tskid] & TA_ACT$
		$init_rdypmap = init_rdypmap + tsk_index$
	$END$
	$tsk_index = tsk_index << 1$
$END$
};$NL$

const uint_t$TAB$_kernel_init_rdypmap = $init_rdypmap$U;$NL$

$ 拡張情報(exinf)． エラーはコンパイル時またはアプリのテストで検出するため，ここではしない．
const intptr_t	_kernel_tinib_exinf[TNUM_TSKID]     = {
$JOINEACH tskid tsk_apriorder_list ","$
	(intptr_t)($TSK.EXINF[tskid]$)
$END$
};$NL$

$ 起動番地(task)．エラーはコンパイル時またはアプリのテストで検出するため，ここではしない．
const TASK    	_kernel_tinib_task[TNUM_TSKID]      = {
$JOINEACH tskid tsk_apriorder_list ","$
	($TSK.TASK[tskid]$)
$END$
};$NL$

$ 起動優先度(atskpri)．
$FOREACH tskid tsk_apriorder_list$
$	// atskpri は TMIN_TPRI 以上，TMAX_TPRI 以下である．（E_PAR）
 	$IF !(TMIN_TPRI <= TSK.ATSKPRI[tskid] && TSK.ATSKPRI[tskid] <= TMAX_TPRI)$
 		$ERROR TSK.TEXT_LINE[tskid]$E_PAR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "atskpri", TSK.ATSKPRI[tskid], tskid, "CRE_TSK")$$END$
 	$END$

$	// atskpri は重複がない．（E_PAR）
	$FOREACH tskid2 tsk_apriorder_list$
		$IF tskid != tskid2 && TSK.ATSKPRI[tskid] == TSK.ATSKPRI[tskid2] $
			$ERROR TSK.TEXT_LINE[tskid]$E_PAR: $FORMAT(_("%1% of %2% (%3%) in %4% is duplicated"), "atskpri", tskid, TSK.ATSKPRI[tskid], "CRE_TSK")$$END$
		$END$
	$END$
$END$

$ 実行時優先度(etskpri)．
const uint_t  	_kernel_tinib_epriority[TNUM_TSKID] = {
$epri_allocated = 0$
$tsk_index = 0$
$JOINEACH tskid tsk_apriorder_list ","$
	$epri = AT(tsk_epri_list, tsk_index)$

$	// etskpri は TMIN_TPRI 以上である．(E_PAR)
	$IF TMIN_TPRI > epri$
		$ERROR TSK.TEXT_LINE[tskid]$E_PAR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "etskpri", epri, tskid, "CRE_TSK")$$END$
	$END$

$	// etskpri は atskpri 以下の値をもつ(優先度としては同じかそれより高い)．(E_PAR)
	$IF epri > TSK.ATSKPRI[tskid]$
		$ERROR TSK.TEXT_LINE[tskid]$E_PAR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "etskpri", epri, tskid, "CRE_TSK")$$END$
	$END$

$	// etskpri の内部表現を決定し reallocate_tskepri に格納．
	$FOREACH tskid2 tsk_apriorder_list $
	 	$IF epri_allocated != 1 && epri <= TSK.ATSKPRI[tskid2]$
			INT_PRIORITY($reallocate_tskapri[TSK.TSKID[tskid2]]$)
				$reallocate_tskepri[tskid] = reallocate_tskapri[TSK.TSKID[tskid2]]$
			$epri_allocated = 1$
		$END$
	$END$
	$epri_allocated = 0$
	$tsk_index = tsk_index + 1$
$END$
};$NL$$NL$

$ 
$ // 優先度割り当てに関する結果を標準出力へ表示
$ 
$FILE "stdout"$
=====================================$NL$
Task priority configuration result:$NL$
$FOREACH tskid SORT(TSK.ORDER_LIST, "TSK.ATSKPRI")$
	$TAB$$TSK.TSKID[tskid]$:$TAB$ IPRI = $reallocate_tskapri[TSK.TSKID[tskid]]$, EXEPRI = $reallocate_tskepri[tskid]$$NL$
$END$
=====================================$NL$
$ 
$ // 出力先をファイルに戻し，優先度割り当て結果を出力
$ 
$FILE "kernel_cfg.c"$
/*$NL$
$SPC$* Task priority configuration result:$NL$
$FOREACH tskid SORT(TSK.ORDER_LIST, "TSK.ATSKPRI")$
$SPC$*  $TAB$$TSK.TSKID[tskid]$:$TAB$ IPRI = $reallocate_tskapri[TSK.TSKID[tskid]]$, EXEPRI = $reallocate_tskepri[tskid]$$NL$
$END$
$SPC$*/$NL$$NL$

$ 
$  タスクの最大スタック使用量の計算
$ 

$ スタックサイズに関するエラーチェック
$FOREACH tskid TSK.ID_LIST$
$	// stkszが0か，ターゲット定義の最小値（TARGET_MIN_STKSZ）よりも小さい場合（E_PAR）
	$IF TSK.STKSZ[tskid] == 0 || (LENGTH(TARGET_MIN_STKSZ) && 
										TSK.STKSZ[tskid] < TARGET_MIN_STKSZ)$
		$ERROR TSK.TEXT_LINE[tskid]$E_PAR: $FORMAT(_("%1% `%2%\' of `%3%\' in %4% is too small"), "stksz", TSK.STKSZ[tskid], tskid, "CRE_TSK")$$END$
	$END$
$END$

$  
$ 関数定義
$ 
$ 
$ 関数1: 起動時優先度の低い順にソーティングするための比較関数
$ 
$FUNCTION compare_tskapri_rev$
	$RESULT = reallocate_tskapri[ARGV[2]] - reallocate_tskapri[ARGV[1]]$
$END$

$ 
$ 関数2: 指定したタスクに対するスタック使用量の最大を計算する関数
$    引数 : ARGV[1] : タスクID(内部表現, 起動時優先度の内部表現に等しい)
$    返値 : RESULT  : 当該タスクに対するスタック使用量の最大値．
$                     この値は，当該タスクの実行開始から終了までの間に
$                     そのタスクに対するプリエンプトを考慮してスタック使用量を
$                     計算した場合に，可能性のある組み合わせの中で最大となる値を返す．
$ 
$nest_level = 0$
$ 
$FUNCTION calc_stksz$
$	// 変数リスト
	$nest_level = nest_level + 1$
	$arg[nest_level] = ARGV[1]$
	$calculated_stack_size = 0$

$	// 処理開始
$SPC$* $LOG(nest_level-1)$Calculation start (Task ID = $arg[nest_level]$, StackSize[$arg[nest_level]$]=$TSK.STKSZ[arg[nest_level]]$)$NL$

$	// 指定したタスクID のスタック計算が完了しているか
	$IF	LENGTH(done[arg[nest_level]]) == 0$

$SPC$* $LOG(nest_level)$Task list with higher priority than $arg[nest_level]$ = $higher_pri_tsklist[arg[nest_level]]$$NL$

$		// (1) 完了していない場合
$		// 変数の初期化
		$max_stksz[arg[nest_level]] = 0$
		$higher_pri_maxstksz[arg[nest_level]] = 0$

$		// 当該タスクID の実行時優先度より高い起動優先度を持つタスクが存在する場合
		$IF LENGTH(higher_pri_tsklist[arg[nest_level]]) > 0$
$			// それぞれの高優先度タスクに対し
			$FOREACH id higher_pri_tsklist[arg[nest_level]]$
$				// 再帰呼出すると変数が上書きされるため，保存しておく
				$id_saved[nest_level] = id$
$				// スタック計算を実行する
				$calculated_stack_size = calc_stksz(id_saved[nest_level])$
$				// 保存した変数を復帰
				$id = id_saved[nest_level]$

				$IF higher_pri_maxstksz[arg[nest_level]] < calculated_stack_size$
$					// 記憶しておく
					$higher_pri_maxstksz[arg[nest_level]] = calculated_stack_size$
				$END$
			$END$
		$END$

$SPC$* $LOG(nest_level)$higher_pri_maxstksz[$arg[nest_level]$] = $higher_pri_maxstksz[arg[nest_level]]$$NL$

$		// 高優先度タスクのスタック使用量に，当該タスクの使用量を加算する
		$max_stksz[arg[nest_level]] = higher_pri_maxstksz[arg[nest_level]] + TSK.STKSZ[arg[nest_level]]$

$SPC$* $LOG(nest_level)$DONE(max_stksz[$arg[nest_level]$] = $max_stksz[arg[nest_level]]$)$NL$

$		// 当該タスクIDに対しては計算を済ませたという記録を残しておく
		$done[arg[nest_level]] = 1$

	$ELSE$
$		// (2) 計算が既に完了している場合，計算をスキップする．

$SPC$* $LOG(nest_level)$SKIP(max_stksz[$arg[nest_level]$] = $max_stksz[arg[nest_level]]$)$NL$
	$END$

$	// 見積もりの最大値を返す
	$RESULT = max_stksz[arg[nest_level]]$
	$nest_level = nest_level - 1$
$END$

$ 
$ 関数定義ここまで，ここからスタック計算処理の開始
$ 

$ 
$ まずは木構造のデータ構造作成
$ 
$FOREACH id LSORT(tsk_apriorder_list, "compare_tskapri_rev")$

$	// 各タスク毎に，その実行時優先度よりも高い起動時優先度を持つタスクのリストを作る．
$	// それはプリエンプトされる可能性のあるタスクの一覧となる．
	$FOREACH id2 LSORT(tsk_apriorder_list, "compare_tskapri_rev")$
		$IF reallocate_tskepri[id] > reallocate_tskapri[id2]$
			$higher_pri_tsklist[id] = APPEND(higher_pri_tsklist[id], id2)$
		$END$
	$END$

$	// プリエンプトする・される関係を示す木構造の根(root)となるタスクの探索．
$	//   対象タスク(id)の起動時優先度(reallocate_tskapri[id])より低い
$	//   (値としては大きい)起動時優先度をもつタスクの higher_pri_tsklist に，
$	//   対象タスク(id) が含まれなければ，根となる．
	$is_root = 1$
	$FOREACH id2 LSORT(tsk_apriorder_list, "compare_tskapri_rev")$
		$IF (is_root == 1) && (reallocate_tskapri[id] < reallocate_tskapri[id2])$
			$IF LENGTH(FIND(higher_pri_tsklist[id2], id)) > 0$
				$is_root = 0$
			$END$
		$END$
	$END$
$	// 根(root)となるタスクならば，リストへ追加
	$IF is_root == 1$
		$root_apri = APPEND(root_apri, id)$
	$END$
$END$

$ 
$ 出力開始
$ 

/* $NL$
$SPC$* Task Stack Size Estimation: $NL$
$SPC$* $NL$

$ // 根となる各タスクに対して，その最大タスク使用量を計算し，リストへ追加する．
$FOREACH root_id root_apri$
	$stksz_estimated = APPEND(stksz_estimated, calc_stksz(root_id))$
$END$

$ // タスクのスタック使用量の最大値を決定
$ // リスト中の要素の最大値がタスクの最大スタック使用量となる．
$max_tsk_stksz = 0$
$FOREACH size stksz_estimated$
	$IF size > max_tsk_stksz$
		$max_tsk_stksz = size$
	$END$
$END$

$ // 確認
$SPC$* List of Estimated Total Stack Sizes of Tasks = $stksz_estimated$$NL$
$SPC$* Estimated Maximum Total Stack Size of Tasks = $max_tsk_stksz$$NL$
$SPC$*/ $NL$$NL$


$ 全ての処理単位のスタックは共有される．
$ そのため，スタックサイズに関するチェックは
$ 共有スタック設定のところでまとめて行う．

$ スタックの先頭番地(stk)．
$FOREACH tskid tsk_apriorder_list$
$	// 常に NULL である．(E_PAR)
	$IF !EQ(TSK.STK[tskid], "NULL")$
		$ERROR TSK.TEXT_LINE[tskid]$E_PAR: $FORMAT(("'%1%' of %2% must be NULL."), "stk", "CRE_TSK")$$END$
	$END$
$END$



$ ---------------------------------------------------------------------
$  割込み管理機能
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Interrupt Management Functions$NL$
$SPC$*/$NL$
$NL$

$ // INTNO_ATTISR_VALID の要素が重複していないかどうかのチェック
$i = 0$
$FOREACH intno INTNO_ATTISR_VALID$
	$j = 0$
	$FOREACH intno2 INTNO_ATTISR_VALID$
		$IF i < j && intno == intno2$
			$ERROR$ $FORMAT(_("intno (%1%) of INTNO_ATTISR_VALID is duplicated"), intno)$$END$
		$END$
		$j = j + 1$
	$END$
	$i = i + 1$
$END$

$ // INHNO_ATTISR_VALID の要素が重複していないかどうかのチェック
$i = 0$
$FOREACH intno INHNO_ATTISR_VALID$
	$j = 0$
	$FOREACH intno2 INHNO_ATTISR_VALID$
		$IF i < j && intno == intno2$
			$ERROR$ $FORMAT(_("intno (%1%) of INHNO_ATTISR_VALID is duplicated"), intno)$$END$
		$END$
		$j = j + 1$
	$END$
	$i = i + 1$
$END$


$ // ATT_ISR で使用可能な割込み番号と，それに対応する割込みハンドラ番号の数が同じかどうか
$ // 各リストの要素は重複していないことを前提としている．
$IF LENGTH(INTNO_ATTISR_VALID) != LENGTH(INHNO_ATTISR_VALID)$
	$ERROR$length of `INTNO_ATTISR_VALID' is different from length of `INHNO_ATTISR_VALID'$END$
$END$


$ // 割込み番号と割込みハンドラ番号の変換テーブルの作成
$ //  割込み番号のリストと割込みハンドラ番号のリストは対応する要素が同じ順番で
$ //  現れるように並べられていることを前提とする．
$i = 0$
$FOREACH intno INTNO_ATTISR_VALID$

$	// INTNO_ATTISR_VALID に含まれる値は INTNO_CFGINT_VALID にも含まれるべきである．
$	// INTNO_ATTISR_VALID は INTNO_CFGINT_VALID の部分集合になるはず．
	$IF LENGTH(FIND(INTNO_CFGINT_VALID, intno)) == 0$
		$ERROR$all elements of `INTNO_ATTISR_VALID' must be included in `INTNO_CFGINT_VALID'$END$
	$END$

	$inhno = AT(INHNO_ATTISR_VALID, i)$
	$INHNO[intno] = inhno$
	$INTNO[inhno] = intno$
	$i = i + 1$
$END$


$ // INTNO_CFGINT_VALID の要素が INTNO_VALID に含まれるかどうかのチェック
$ // INTNO_CFGINT_VALID は INTNO_VALID の部分集合になるはず．
$FOREACH intno INTNO_CFGINT_VALID$
	$IF LENGTH(FIND(INTNO_VALID, intno)) == 0$
		$ERROR$all elements of `INTNO_CFGINT_VALID' must be included in `INTNO_VALID'$END$
	$END$
$END$


$ // INHNO_ATTISR_VALID の要素が INHNO_VALID に含まれるかどうかのチェック
$ // INHNO_ATTISR_VALID は INHNO_VALID の部分集合になるはず．
$FOREACH inhno INHNO_ATTISR_VALID$
	$IF LENGTH(FIND(INHNO_VALID, inhno)) == 0$
		$ERROR$all elements of `INHNO_ATTISR_VALID' must be included in `INHNO_VALID'$END$
	$END$
$END$


$ // 割込み要求ラインに関するエラーチェック
$i = 0$
$FOREACH intno INT.ORDER_LIST$
$	// intnoがCFG_INTに対する割込み番号として正しくない場合（E_PAR）
	$IF !LENGTH(FIND(INTNO_CFGINT_VALID, INT.INTNO[intno]))$
		$ERROR INT.TEXT_LINE[intno]$E_PAR: $FORMAT(_("illegal %1% `%2%\' in %3%"), "intno", INT.INTNO[intno], "CFG_INT")$$END$
	$END$

$	// intnoがCFG_INTによって設定済みの場合（E_OBJ）
	$j = 0$
	$FOREACH intno2 INT.ORDER_LIST$
 		$IF INT.INTNO[intno] == INT.INTNO[intno2] && j < i$
			$ERROR INT.TEXT_LINE[intno]$E_OBJ: $FORMAT(_("%1% `%2%\' in %3% is duplicated"), "intno", INT.INTNO[intno], "CFG_INT")$$END$
		$END$
		$j = j + 1$
	$END$

$	// intatrが TA_ENAINT, TA_EDGE, またはその他ターゲットで利用可能な属性のいずれでもない場合（E_RSATR）
	$IF (INT.INTATR[intno] & ~(TA_ENAINT|TA_EDGE|ALT(TARGET_INTATR,0))) != 0$
		$ERROR INT.TEXT_LINE[intno]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of %3% `%4%\' in %5%"), "intatr", INT.INTATR[intno], "intno", INT.INTNO[intno], "CFG_INT")$$END$
	$END$

$	// intpriがCFG_INTに対する割込み優先度として正しくない場合（E_PAR）
	$IF !LENGTH(FIND(INTPRI_CFGINT_VALID, INT.INTPRI[intno]))$
		$ERROR INT.TEXT_LINE[intno]$E_PAR: $FORMAT(_("illegal %1% `%2%\' in %3%"), "intpri", INT.INTPRI[intno], "CFG_INT")$$END$
	$END$

$	// カーネル管理の割込みとして固定されている割込みに，TMIN_INTPRI よりも小さい値が指定された場合（E_OBJ）
	$IF LENGTH(FIND(INTNO_FIX_KERNEL, intno))$
		$IF INT.INTPRI[intno] < TMIN_INTPRI$
			$ERROR INT.TEXT_LINE[intno]$E_OBJ: $FORMAT(_("%1% `%2%\' must not have higher priority than %3%"), "intno", INT.INTNO[intno], "TMIN_INTPRI")$$END$
		$END$
	$END$

$	// カーネル管理外の割込みとして固定されている割込みに，TMIN_INTPRI よりも小さい値が指定されなかった場合（E_OBJ）
	$IF LENGTH(FIND(INTNO_FIX_NONKERNEL, intno))$
		$IF INT.INTPRI[intno] >= TMIN_INTPRI$
			$ERROR INT.TEXT_LINE[intno]$E_OBJ: $FORMAT(_("%1% `%2%\' must have higher priority than %3%"), "intno", INT.INTNO[intno], "TMIN_INTPRI")$$END$
		$END$
	$END$
	$i = i + 1$
$END$


$ 割込みハンドラに関するエラーチェック
$i = 0$
$FOREACH inhno INH.ORDER_LIST$
$	// 割込みハンドラ番号(inhno)が正しくない場合（E_PAR）
	$IF !LENGTH(FIND(INHNO_DEFINH_VALID, INH.INHNO[inhno]))$
		$ERROR INH.TEXT_LINE[inhno]$E_PAR: $FORMAT(_("illegal %1% `%2%\' in %3%"), "inhno", INH.INHNO[inhno], "DEF_INH")$$END$
	$END$

$	// 同じ割込みハンドラ番号に対するDEF_INHが複数存在する場合（E_OBJ）
	$j = 0$
	$FOREACH inhno2 INH.ORDER_LIST$
		$IF INH.INHNO[inhno] == INH.INHNO[inhno2] && j < i$
			$ERROR INH.TEXT_LINE[inhno]$E_OBJ: $FORMAT(_("%1% `%2%\' in %3% is duplicated"), "inhno", INH.INHNO[inhno], "DEF_INH")$$END$
		$END$
		$j = j + 1$
	$END$

$	// 割込みハンドラ属性(inhatr) が TA_NULL, TA_NONKERNEL, 及びその他ターゲット依存で利用可能な属性のいずれでもない（E_RSATR）
	$IF (INH.INHATR[inhno] & ~(TA_NONKERNEL|ALT(TARGET_INHATR,0))) != 0$
		$ERROR INH.TEXT_LINE[inhno]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of %3% `%4%\' in %5%"), "inhatr", INH.INHATR[inhno], "inhno", INH.INHNO[inhno], "DEF_INH")$$END$
	$END$

$	// カーネル管理に固定されている割込みハンドラに，TA_NONKERNEL 属性が設定されている（E_RSATR）
	$IF LENGTH(FIND(INHNO_FIX_KERNEL, inhno))$
		$IF (INH.INHATR[inhno] & TA_NONKERNEL) != 0$
			$ERROR INH.TEXT_LINE[inhno]$E_RSATR: $FORMAT(_("%1% `%2%\' must not be non-kernel interrupt"), "inhno", INH.INHNO[inhno])$$END$
		$END$
	$END$

$	// カーネル管理外に固定されている割込みハンドラに，TA_NONKERNEL 属性が設定されていない（E_RSATR）
	$IF LENGTH(FIND(INHNO_FIX_NONKERNEL, inhno))$
		$IF (INH.INHATR[inhno] & TA_NONKERNEL) == 0$
			$ERROR INH.TEXT_LINE[inhno]$E_RSATR: $FORMAT(_("%1% `%2%\' must be non-kernel interrupt"), "inhno", INH.INHNO[inhno])$$END$
		$END$
	$END$


$	// 割込み番号と1対1対応する割込みハンドラ番号(ATT_ISRで指定可能な割込みハンドラ番号)は，以下のチェックも行う．
$	// INHNO_ATTISR_VALID に含まれない割込みハンドラ番号はチェックされないことになる．
	$IF LENGTH(INTNO[INH.INHNO[inhno]]) > 0$
		$intno = INTNO[INH.INHNO[inhno]]$

$		// 割込みハンドラ登録先の割込み要求ラインが属性設定されていない(CFG_INTがない)（E_OBJ）
		$IF !LENGTH(INT.INTNO[intno])$
			$ERROR INH.TEXT_LINE[inhno]$E_OBJ: $FORMAT(_("%1% `%2%\' corresponding to %3% `%4%\' is not configured with %5%"), "intno", INT.INTNO[intno], "inhno", INH.INHNO[inhno], "CFG_INT")$$END$
		$ELSE$
			$IF (INH.INHATR[inhno] & TA_NONKERNEL) == 0$
$				// inhatrにTA_NONKERNELが指定されておらず，inhnoに対応
$				// するintnoに対してCFG_INTで設定された割込み優先度が
$				// TMIN_INTPRIよりも小さい場合（E_OBJ）
				$IF INT.INTPRI[intno] < TMIN_INTPRI$
					$ERROR INT.TEXT_LINE[intno]$E_OBJ: $FORMAT(_("%1% `%2%\' configured for %3% `%4%\' is higher than %5%"), "intpri", INT.INTPRI[intno], "inhno", INH.INHNO[inhno], "TMIN_INTPRI")$$END$
				$END$
			$ELSE$
$				// inhatrにTA_NONKERNELが指定されており，inhnoに対応
$				// するintnoに対してCFG_INTで設定された割込み優先度が
$				// TMIN_INTPRI以上である場合（E_OBJ）
				$IF INT.INTPRI[intno] >= TMIN_INTPRI$
					$ERROR INT.TEXT_LINE[intno]$E_OBJ: $FORMAT(_("%1% `%2%\' configured for %3% `%4%\' is lower than or equal to %5%"), "intpri", INT.INTPRI[intno], "inhno", INH.INHNO[inhno], "TMIN_INTPRI")$$END$
				$END$
			$END$
		$END$
	$END$
	$i = i + 1$
$END$

$ 割込みサービスルーチン（ISR）に関するエラーチェックと割込みハンドラの生成
$FOREACH order ISR.ORDER_LIST$
$	// isratrが（TA_NULL）でない場合（E_RSATR）
	$IF (ISR.ISRATR[order] & ~ALT(TARGET_ISRATR,0)) != 0$
		$ERROR ISR.TEXT_LINE[order]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of %3% `%4%\' in %5%"), "isratr", ISR.ISRATR[order], "isr", ISR.ISR[order], "ATT_ISR")$$END$
	$END$

$	// intnoがATT_ISRに対する割込み番号として正しくない場合（E_PAR）
	$IF !LENGTH(FIND(INTNO_ATTISR_VALID, ISR.INTNO[order]))$
		$ERROR ISR.TEXT_LINE[order]$E_PAR: $FORMAT(_("illegal %1% `%2%\' in %3%"), "intno", ISR.INTNO[order], "ATT_ISR")$$END$
	$END$

$	// (TMIN_ISRPRI <= isrpri && isrpri <= TMAX_ISRPRI)でない場合（E_PAR）
	$IF !(TMIN_ISRPRI <= ISR.ISRPRI[order] && ISR.ISRPRI[order] <= TMAX_ISRPRI)$
		$ERROR ISR.TEXT_LINE[order]$E_PAR: $FORMAT(_("illegal %1% `%2%\' in %3%"), "isrpri", ISR.ISRPRI[order], "ATT_ISR")$$END$
	$END$
$END$


$FOREACH intno INTNO_ATTISR_VALID$
	$inhno = INHNO[intno]$

$	// 割込み番号intnoに対して登録されたISRのリストの作成
	$isr_order_list = {}$
	$FOREACH order ISR.ORDER_LIST$
		$IF ISR.INTNO[order] == intno$
			$isr_order_list = APPEND(isr_order_list, order)$
			$order_for_error = order$
		$END$
	$END$

$	// 割込み番号intnoに対して登録されたISRが存在する場合
	$IF LENGTH(isr_order_list) > 0$
$		// intnoに対応するinhnoに対してDEF_INHがある場合（E_OBJ）
		$IF LENGTH(INH.INHNO[inhno])$
			$ERROR ISR.TEXT_LINE[order_for_error]$E_OBJ: $FORMAT(_("%1% `%2%\' in %3% is duplicated with %4% `%5%\'"), "intno", ISR.INTNO[order_for_error], "ATT_ISR", "inhno", INH.INHNO[inhno])$$END$
		$END$

$		// intnoに対するCFG_INTがない場合（E_OBJ）
		$IF !LENGTH(INT.INTNO[intno])$
			$ERROR ISR.TEXT_LINE[order_for_error]$E_OBJ: $FORMAT(_("%1% `%2%\' is not configured with %3%"), "intno", ISR.INTNO[order_for_error], "CFG_INT")$$END$
		$ELSE$
$			// intnoに対してCFG_INTで設定された割込み優先度がTMIN_INTPRI
$			// よりも小さい場合（E_OBJ）
			$IF INT.INTPRI[intno] < TMIN_INTPRI$
				$ERROR INT.TEXT_LINE[intno]$E_OBJ: $FORMAT(_("%1% `%2%\' configured for %3% `%4%\' is higher than %5%"), "intpri", INT.INTPRI[intno], "intno", ISR.INTNO[order_for_error], "TMIN_INTPRI")$$END$
			$END$
		$END$

$		// DEF_INH(inhno, { TA_NULL, _kernel_inthdr_<intno> } );
		$INH.INHNO[inhno] = inhno$
		$INH.INHATR[inhno] = VALUE("TA_NULL", 0)$
		$INH.INTHDR[inhno] = CONCAT("_kernel_inthdr_", intno)$
		$INH.ORDER_LIST = APPEND(INH.ORDER_LIST, inhno)$

$		// ISR用の割込みハンドラ
		void$NL$
		_kernel_inthdr_$intno$(void)$NL$
		{$NL$
		$IF LENGTH(isr_order_list) > 1$
			$TAB$PRI	saved_ipm;$NL$
			$NL$
			$TAB$i_begin_int($intno$);$NL$
			$TAB$saved_ipm = i_get_ipm();$NL$
		$ELSE$
			$TAB$i_begin_int($intno$);$NL$
		$END$
$		// ISRを優先度順に呼び出す
		$JOINEACH order SORT(isr_order_list, "ISR.ISRPRI") "\tif (i_sense_lock()) {\n\t\ti_unlock_cpu();\n\t}\n\ti_set_ipm(saved_ipm);\n"$
			$TAB$LOG_ISR_ENTER($intno$);$NL$
			$TAB$((ISR)($ISR.ISR[order]$))((intptr_t)($ISR.EXINF[order]$));$NL$
			$TAB$LOG_ISR_LEAVE($intno$);$NL$
		$END$
		$TAB$i_end_int($intno$);$NL$
		}$NL$
	$END$
$END$
$NL$

$ 割込み管理機能のための標準的な初期化情報の生成
$IF !ALT(OMIT_INITIALIZE_INTERRUPT,0)$

$ 割込みハンドラ数
#define TNUM_INHNO	$LENGTH(INH.ORDER_LIST)$$NL$
const uint_t _kernel_tnum_inhno = TNUM_INHNO;$NL$
$NL$
$FOREACH inhno INH.ORDER_LIST$
	INTHDR_ENTRY($INH.INHNO[inhno]$, $+INH.INHNO[inhno]$, $INH.INTHDR[inhno]$)$NL$$NL$
$END$

$ 割込みハンドラ初期化テーブル
$IF LENGTH(INH.ORDER_LIST)$
	const INHNO _kernel_inhinib_inhno[TNUM_INHNO] = {
	$JOINEACH inhno INH.ORDER_LIST ","$
		($INH.INHNO[inhno]$)
	$END$
	};$NL$

	const ATR _kernel_inhinib_inhatr[TNUM_INHNO] = {
	$JOINEACH inhno INH.ORDER_LIST ","$
		($INH.INHATR[inhno]$)
	$END$
	};$NL$

	const FP _kernel_inhinib_entry[TNUM_INHNO] = {
	$JOINEACH inhno INH.ORDER_LIST ","$
		(FP)(INT_ENTRY($INH.INHNO[inhno]$, $INH.INTHDR[inhno]$))
	$END$
	};$NL$
$ELSE$
	TOPPERS_EMPTY_LABEL(const INHNO, _kernel_inhinib_inhno);$NL$
	TOPPERS_EMPTY_LABEL(const ATR, _kernel_inhinib_inhatr);$NL$
	TOPPERS_EMPTY_LABEL(const FP, _kernel_inhinib_entry);$NL$
$END$
$NL$

$ 割込み要求ライン数
#define TNUM_INTNO	$LENGTH(INT.ORDER_LIST)$$NL$
const uint_t _kernel_tnum_intno = TNUM_INTNO;$NL$
$NL$

$ 割込み要求ライン初期化テーブル
$IF LENGTH(INT.ORDER_LIST)$
	const INTNO _kernel_intinib_intno[TNUM_INTNO] = {
	$JOINEACH intno INT.ORDER_LIST ","$
		($INT.INTNO[intno]$)
	$END$
	};$NL$

	const ATR _kernel_intinib_intatr[TNUM_INTNO] = {
	$JOINEACH intno INT.ORDER_LIST ","$
		($INT.INTATR[intno]$)
	$END$
	};$NL$

	const PRI _kernel_intinib_intpri[TNUM_INTNO] = {
	$JOINEACH intno INT.ORDER_LIST ","$
		($INT.INTPRI[intno]$)
	$END$
	};$NL$
$ELSE$
	TOPPERS_EMPTY_LABEL(const INTNO, _kernel_intinib_intno);$NL$
	TOPPERS_EMPTY_LABEL(const ATR, _kernel_intinib_intatr);$NL$
	TOPPERS_EMPTY_LABEL(const PRI, _kernel_intinib_intpri);$NL$
$END$
$NL$
$END$

$ ---------------------------------------------------------------------
$  CPU例外ハンドラ
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  CPU Exception Handler$NL$
$SPC$*/$NL$
$NL$

$ // EXCNO_DEFEXC_VALID の要素が EXCNO_VALID に含まれるかどうかのチェック
$ // EXCNO_DEFEXC_VALID は EXCNO_VALID の部分集合になるはず．
$FOREACH excno EXCNO_DEFEXC_VALID$
	$IF LENGTH(FIND(EXCNO_VALID, excno)) == 0$
		$ERROR$all elements of `EXCNO_DEFEXC_VALID' must be included in `EXCNO_VALID'$END$
	$END$
$END$


$ CPU例外ハンドラに関するエラーチェック
$i = 0$
$FOREACH excno EXC.ORDER_LIST$
$	// excnoがDEF_EXCに対するCPU例外ハンドラ番号として正しくない場合（E_PAR）
	$IF !LENGTH(FIND(EXCNO_DEFEXC_VALID, EXC.EXCNO[excno]))$
		$ERROR EXC.TEXT_LINE[excno]$E_PAR: $FORMAT(_("illegal %1% `%2%\' in %3%"), "excno", EXC.EXCNO[excno], "DEF_EXC")$$END$
	$END$

$	// excnoがDEF_EXCによって設定済みの場合（E_OBJ）
	$j = 0$
	$FOREACH excno2 EXC.ORDER_LIST$
		$IF EXC.EXCNO[excno] == EXC.EXCNO[excno2] && j < i$
			$ERROR EXC.TEXT_LINE[excno]$E_OBJ: $FORMAT(_("%1% `%2%\' in %3% is duplicated"), "excno", EXC.EXCNO[excno], "DEF_EXC")$$END$
		$END$
		$j = j + 1$
	$END$

$	// excatrが（TA_NULL）でない場合（E_RSATR）
	$IF (EXC.EXCATR[excno] & ~ALT(TARGET_EXCATR,0)) != 0$
		$ERROR EXC.TEXT_LINE[excno]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of %3% `%4%\' in %5%"), "excatr", EXC.EXCATR[excno], "excno", EXC.EXCNO[excno], "DEF_EXC")$$END$
	$END$
	$i = i + 1$
$END$

$ CPU例外ハンドラのための標準的な初期化情報の生成
$IF !ALT(OMIT_INITIALIZE_EXCEPTION,0)$

$ CPU例外ハンドラ数
#define TNUM_EXCNO	$LENGTH(EXC.ORDER_LIST)$$NL$
const uint_t _kernel_tnum_excno = TNUM_EXCNO;$NL$
$NL$
$FOREACH excno EXC.ORDER_LIST$
	EXCHDR_ENTRY($EXC.EXCNO[excno]$, $+EXC.EXCNO[excno]$, $EXC.EXCHDR[excno]$)$NL$$NL$
$END$

$ CPU例外ハンドラ初期化テーブル
$IF LENGTH(EXC.ORDER_LIST)$
	const EXCNO _kernel_excinib_excno[TNUM_EXCNO] = {
	$JOINEACH excno EXC.ORDER_LIST ","$
		($EXC.EXCNO[excno]$)
	$END$
	};$NL$

	const ATR _kernel_excinib_excatr[TNUM_EXCNO] = {
	$JOINEACH excno EXC.ORDER_LIST ","$
		($EXC.EXCATR[excno]$)
	$END$
	};$NL$

	const FP _kernel_excinib_entry[TNUM_EXCNO] = {
	$JOINEACH excno EXC.ORDER_LIST ","$
		(FP)(EXC_ENTRY($EXC.EXCNO[excno]$, $EXC.EXCHDR[excno]$))
	$END$
	};$NL$
$ELSE$
	TOPPERS_EMPTY_LABEL(const EXCNO, _kernel_excinib_excno);$NL$
	TOPPERS_EMPTY_LABEL(const ATR, _kernel_excinib_excatr);$NL$
	TOPPERS_EMPTY_LABEL(const FP, _kernel_excinib_entry);$NL$
$END$
$NL$
$END$


$ ---------------------------------------------------------------------
$  周期ハンドラ
$ ---------------------------------------------------------------------

/*$NL$
$SPC$*  Cyclic Handler Functions$NL$
$SPC$*/$NL$
$NL$

$ 周期ハンドラID番号の最大値
const ID _kernel_tmax_cycid = (TMIN_CYCID + TNUM_CYCID - 1);$NL$

$ 周期ハンドラのタイムイベントIDオフセット
$ 周期ハンドラのタイムイベントIDは0から開始
const uint_t _kernel_cycevtid_offset = 0;$NL$
$NL$

$ エントリが16個より多い場合は，エラーとする
$IF LENGTH(CYC.ORDER_LIST) > 16$
	$ERROR$$FORMAT("The number of CRE_CYC must be equal to or less than 16.")$$END$
$END$

$IF LENGTH(CYC.ORDER_LIST)$
$	周期ハンドラ属性
	$CYCACT = 0$
	$FOREACH cycid CYC.ORDER_LIST$
$		// 周期ハンドラ属性(cycatr) が TA_NULL, TA_STA のいずれでもない（E_RSATR）
		$IF (CYC.CYCATR[cycid] & ~TA_STA) != 0$
			$ERROR CYC.TEXT_LINE[cycid]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "cycatr", CYC.CYCATR[cycid], cycid, "CRE_CYC")$$END$
		$END$

		$IF(CYC.CYCATR[cycid] & TA_STA)$
			$CYCACT = CYCACT | (1 << (cycid-1))$
		$END$
	$END$
	const uint16_t _kernel_cycinib_cycact = $CYCACT$;$NL$

$	周期ハンドラ拡張情報
	const intptr_t _kernel_cycinib_exinf[TNUM_CYCID] = {
	$JOINEACH cycid CYC.ORDER_LIST ","$
		(intptr_t)($CYC.EXINF[cycid]$)
	$END$
	};$NL$

$	周期ハンドラアドレス
	const CYCHDR _kernel_cycinib_cychdr[TNUM_CYCID] = {
	$JOINEACH cycid CYC.ORDER_LIST ","$
		($CYC.CYCHDR[cycid]$)
	$END$
	};$NL$

$	周期ハンドラ周期
	const RELTIM _kernel_cycinib_cyctim[TNUM_CYCID] = {
	$JOINEACH cycid CYC.ORDER_LIST ","$
$		// cyctim は 0 より大きく，TMAX_RELTIM 以下である．(E_PAR)
		$IF CYC.CYCTIM[cycid] <= 0 || TMAX_RELTIM < CYC.CYCTIM[cycid] $
			$ERROR CYC.TEXT_LINE[cycid]$E_PAR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "cyctim", CYC.CYCTIM[cycid], cycid, "CRE_CYC")$$END$
		$END$

		($CYC.CYCTIM[cycid]$)
	$END$
	};$NL$

$	周期ハンドラ位相
	const RELTIM _kernel_cycinib_cycphs[TNUM_CYCID] = {
	$JOINEACH cycid CYC.ORDER_LIST ","$
$		// cycphs は 0 以上，TMAX_RELTIM 以下である．(E_PAR)
		$IF CYC.CYCPHS[cycid] < 0 || TMAX_RELTIM < CYC.CYCPHS[cycid] $
			$ERROR CYC.TEXT_LINE[cycid]$E_PAR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "cycphs", CYC.CYCPHS[cycid], cycid, "CRE_CYC")$$END$
		$END$

$		// 位相が0かつ，属性が TA_STA の場合は警告
		$IF CYC.CYCPHS[cycid] == 0 && (CYC.CYCATR[cycid] & TA_STA) != 0$
			$WARNING CYC.TEXT_LINE[cycid]$$FORMAT(_("%1% is not recommended when %2% is set to %3% in %4%"), "cycphs==0", "TA_STA", "cycatr", "CRE_CYC")$$END$
		$END$

		($CYC.CYCPHS[cycid]$)
	$END$
	};$NL$
	$NL$

$	周期ハンドラの次回起動時刻
EVTTIM _kernel_cyccb_evttim[TNUM_CYCID];$NL$

$ELSE$
	const uint16_t _kernel_cycinib_cycact = 0;$NL$
	TOPPERS_EMPTY_LABEL(const intptr_t, _kernel_cycinib_exinf);$NL$
	TOPPERS_EMPTY_LABEL(const CYCHDR, _kernel_cycinib_cychdr);$NL$
	TOPPERS_EMPTY_LABEL(const RELTIM, _kernel_cycinib_cyctim);$NL$
	TOPPERS_EMPTY_LABEL(const RELTIM, _kernel_cycinib_cycphs);$NL$
	TOPPERS_EMPTY_LABEL(EVTTIM, _kernel_cyccb_evttim);$NL$
$END$

$	周期ハンドラ動作状態
uint16_t _kernel_cyccb_cycact;$NL$

$NL$
$NL$

$ ---------------------------------------------------------------------
$  アラームハンドラ
$ ---------------------------------------------------------------------

/*$NL$
$SPC$*  Alarm Handler Functions$NL$
$SPC$*/$NL$
$NL$

$ エントリが16個より多い場合は，エラーとする
$IF LENGTH(ALM.ORDER_LIST) > 16$
	$ERROR$$FORMAT("The number of CRE_ALM must be equal to or less than 16.")$$END$
$END$

$ アラームハンドラの最大ID値
const ID _kernel_tmax_almid = (TMIN_ALMID + TNUM_ALMID - 1);$NL$

$ アラームハンドラのタイムイベントIDオフセット
const uint_t _kernel_almevtid_offset = $LENGTH(CYC.ORDER_LIST)$;$NL$
$NL$

$FOREACH almid ALM.ORDER_LIST$
$	// almatrが（TA_NULL）でない場合（E_RSATR）
	$IF ALM.ALMATR[almid] != 0$
		$ERROR ALM.TEXT_LINE[almid]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of `%3%\' in %4%"), "almatr", ALM.ALMATR[almid], almid, "CRE_ALM")$$END$
	$END$
$END$

$IF LENGTH(ALM.ORDER_LIST)$
$	アラームハンドラ先頭番地
	const ALMHDR _kernel_alminib_almhdr[TNUM_ALMID] = {
	$JOINEACH almid ALM.ORDER_LIST ","$
		($ALM.ALMHDR[almid]$)
	$END$
	};$NL$

$	アラームハンドラ拡張情報
	const intptr_t _kernel_alminib_exinf[TNUM_ALMID] = {
	$JOINEACH almid ALM.ORDER_LIST ","$
		(intptr_t)($ALM.EXINF[almid]$)
	$END$
	};$NL$
$NL$
$ELSE$
	TOPPERS_EMPTY_LABEL(const ALMHDR, _kernel_alminib_almhdr);$NL$
	TOPPERS_EMPTY_LABEL(const intptr_t, _kernel_alminib_exinf);$NL$
$NL$
$END$

$ アラームハンドラ状態
uint16_t _kernel_almcb_almact;$NL$
$NL$


$ ---------------------------------------------------------------------
$  タイムイベント管理
$ ---------------------------------------------------------------------

/*$NL$
$SPC$*  Time Event Management$NL$
$SPC$*/$NL$
$NL$

$TNUM_TMEVT = LENGTH(CYC.ORDER_LIST) + LENGTH(ALM.ORDER_LIST)$

#define TNUM_TMEVT $TNUM_TMEVT$$NL$
$NL$

$ タイムイベントブロックのサイズ
const uint_t _kernel_tnum_tmevt_queue = TNUM_TMEVT;$NL$$NL$

$IF TNUM_TMEVT != 0$
$	タイムイベントキュー
	QUEUE _kernel_tmevt_queue[TNUM_TMEVT+1];$NL$
$	タイムイベント時間
	EVTTIM _kernel_tmevt_time[TNUM_TMEVT];$NL$
$	タイムイベントのコールバック
	CBACK _kernel_tmevt_callback[TNUM_TMEVT];$NL$
$	タイムイベントコールバックの引数
	uintptr_t _kernel_tmevt_arg[TNUM_TMEVT];$NL$
	$NL$$NL$
$ELSE$
	TOPPERS_EMPTY_LABEL(QUEUE, _kernel_tmevt_queue);$NL$
	TOPPERS_EMPTY_LABEL(EVTTIM, _kernel_tmevt_time);$NL$
	TOPPERS_EMPTY_LABEL(CBACK, _kernel_tmevt_callback);$NL$
	TOPPERS_EMPTY_LABEL(uintptr_t, _kernel_tmevt_arg);$NL$
	$NL$$NL$
$END$

$ ---------------------------------------------------------------------
$  共有スタック領域
$      SSPではすべての処理単位のスタックを共有するため，
$      ここでシステム全体のスタック領域を確保する．
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Stack Area for System$NL$
$SPC$*/$NL$
$NL$

$ // 変数定義
$ // 割り当てられた共有スタック領域のサイズ
$allocated_stack_size = 0$

$ // DEF_ICS のエントリが存在するか?
$IF !LENGTH(ICS.ORDER_LIST)$
$	// ない場合．サイズは既定値 (DEFAULT_ISTKSZ) を使う
$	// 領域の先頭番地の既定値 (DEFALT_ISTK) は使わない方針とする．
$	// スタック領域の先頭番地を指定する場合は，DEF_ICS を使うこと．
	#define TOPPERS_ISTKSZ		DEFAULT_ISTKSZ$NL$
	static STK_T          		_kernel_stack[COUNT_STK_T(TOPPERS_ISTKSZ)];$NL$
	#define TOPPERS_STK   		_kernel_stack$NL$
	#define TOPPERS_STKSZ		ROUND_STK_T(TOPPERS_ISTKSZ)$NL$
	$NL$

	$allocated_stack_size = DEFAULT_ISTKSZ$
$ELSE$
$	// DEF_ICS のエントリがある場合

$ 
$	// エラーチェック
$ 
$	// 静的API「DEF_ICS」が複数ある（E_OBJ）
	$IF LENGTH(ICS.ORDER_LIST) > 1$
		$ERROR$E_OBJ: $FORMAT(_("too many %1%"), "DEF_ICS")$$END$
	$END$
$	// DEF_ICS で0を指定した場合(E_PAR)
	$IF ICS.ISTKSZ[1] == 0$
		$ERROR ICS.TEXT_LINE[1]$E_PAR: $FORMAT(_("%1% in %2% is 0"), "istksz", "DEF_ICS")$$END$
	$ELSE$
		$allocated_stack_size = ICS.ISTKSZ[1]$
	$END$

	$IF EQ(ICS.ISTK[1], "NULL")$
$		// スタック領域の自動割付け
		#define TOPPERS_ISTKSZ		($ICS.ISTKSZ[1]$)$NL$
		static STK_T				_kernel_stack[COUNT_STK_T(TOPPERS_ISTKSZ)];$NL$
		#define TOPPERS_STK   		_kernel_stack$NL$
		#define TOPPERS_STKSZ		ROUND_STK_T(TOPPERS_ISTKSZ)$NL$
	$ELSE$
$ 		// istkszがターゲット毎に定まるアライメントサイズの倍数にアライメントされていない場合（E_PAR）
		$IF LENGTH(CHECK_STKSZ_ALIGN) && (ICS.ISTKSZ[1] & (CHECK_STKSZ_ALIGN - 1))$
			$ERROR ICS.TEXT_LINE[1]$E_PAR: $FORMAT(_("%1% `%2%\' in %3% is not aligned"), "istksz", ICS.ISTKSZ[1], "DEF_ICS")$$END$
		$END$

		#define TOPPERS_ISTKSZ		($ICS.ISTKSZ[1]$)$NL$
		#define TOPPERS_STK   		($ICS.ISTK[1]$)$NL$
		#define TOPPERS_STKSZ		ROUND_STK_T(TOPPERS_ISTKSZ)$NL$
	$END$
$END$
$NL$

$ 共有スタック用のスタック領域
const SIZE		_kernel_stksz = TOPPERS_STKSZ;$NL$
STK_T *const	_kernel_stk = TOPPERS_STK;$NL$
$NL$
#ifdef TOPPERS_ISTKPT$NL$
STK_T *const	_kernel_istkpt = TOPPERS_ISTKPT(TOPPERS_STK, TOPPERS_STKSZ);$NL$
#endif /* TOPPERS_ISTKPT */$NL$
$NL$

$ 
$ // スタック設定に関する結果を標準出力へ表示
$ 
$FILE "stdout"$
=====================================$NL$
Stack size configuration result:$NL$
$TAB$Estimated task stack size = $max_tsk_stksz$$NL$
$TAB$Allocated total stack size = $allocated_stack_size$(value=$FORMAT("%d",+allocated_stack_size)$)$NL$
$ // サイズのチェック．タスクの推定最大サイズが実際に割当てられた共有スタック領域のサイズより大きい場合，警告する．
$IF max_tsk_stksz > allocated_stack_size$
	$TAB$!!!WARNING!!!: Estimated task stack size is more than the allocated stack size.$NL$
	$WARNING ICS.TEXT_LINE[1]$ $FORMAT("The estimated task stack size is more than the allocated stack size.")$$END$
$END$
=====================================$NL$
$ 
$ // 出力先を元に戻しておく
$ 
$FILE "kernel_cfg.c"$


$ ---------------------------------------------------------------------
$  各モジュールの初期化関数
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Module Initialization Function$NL$
$SPC$*/$NL$
$NL$
void$NL$
_kernel_initialize_object(void)$NL$
{$NL$
$IF TNUM_TMEVT > 0$
$TAB$_kernel_initialize_time_event();$NL$
$END$
$TAB$_kernel_initialize_task();$NL$
$TAB$_kernel_initialize_interrupt();$NL$
$TAB$_kernel_initialize_exception();$NL$
$IF LENGTH(CYC.ID_LIST)$
	$TAB$_kernel_initialize_cyclic();$NL$
$END$
$IF LENGTH(ALM.ID_LIST)$
	$TAB$_kernel_initialize_alarm();$NL$
$END$
}$NL$
$NL$

$ ---------------------------------------------------------------------
$  初期化ルーチンの実行関数
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Initialization Routine$NL$
$SPC$*/$NL$
$NL$
void$NL$
_kernel_call_inirtn(void)$NL$
{$NL$
$FOREACH order INI.ORDER_LIST$
$ 	// iniatrが（TA_NULL）でない場合（E_RSATR）
	$IF INI.INIATR[order] != 0$
		$ERROR INI.TEXT_LINE[order]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of %3% `%4%\' in %5%"), "iniatr", INI.INIATR[order], "inirtn", INI.INIRTN[order], "ATT_INI")$$END$
	$END$
	$TAB$((INIRTN)($INI.INIRTN[order]$))((intptr_t)($INI.EXINF[order]$));$NL$
$END$
}$NL$
$NL$

$ ---------------------------------------------------------------------
$  終了処理ルーチンの実行関数
$ ---------------------------------------------------------------------
/*$NL$
$SPC$*  Termination Routine$NL$
$SPC$*/$NL$
$NL$
void$NL$
_kernel_call_terrtn(void)$NL$
{$NL$
$FOREACH rorder TER.RORDER_LIST$
$ 	// teratrが（TA_NULL）でない場合（E_RSATR）
	$IF TER.TERATR[rorder] != 0$
		$ERROR TER.TEXT_LINE[rorder]$E_RSATR: $FORMAT(_("illegal %1% `%2%\' of %3% `%4%\' in %5%"), "teratr", TER.TERATR[rorder], "terrtn", TER.TERRTN[rorder], "ATT_TER")$$END$
	$END$
	$TAB$((TERRTN)($TER.TERRTN[rorder]$))((intptr_t)($TER.EXINF[rorder]$));$NL$
$END$
}$NL$
$NL$


