$ ======================================================================
$ 
$  TOPPERS/SSP Kernel
$      Smallest Set Profile Kernel
$ 
$   Copyright (C) 2008 by Embedded and Real-Time Systems Laboratory
$               Graduate School of Information Science, Nagoya Univ., JAPAN
$   Copyright (C) 2010 by Naoki Saito
$              Nagoya Municipal Industrial Research Institute, JAPAN
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

$ 
$  関数の先頭番地のチェック
$ 
$IF LENGTH(CHECK_FUNC_ALIGN) || LENGTH(CHECK_FUNC_NONNULL)$
$	// タスクとタスク例外処理ルーチンの先頭番地のチェック
	$tinib = SYMBOL("_kernel_tinib_table")$
	$FOREACH tskid TSK.ID_LIST$
		$task = PEEK(tinib + offsetof_TINIB_task, sizeof_FP)$
		$IF LENGTH(CHECK_FUNC_ALIGN) && (task & (CHECK_FUNC_ALIGN - 1))$
			$ERROR TSK.TEXT_LINE[tskid]$E_PAR: 
				$FORMAT(_("%1% `%2%\' of `%3%\' in %4% is not aligned"),
				"task", TSK.TASK[tskid], tskid, "CRE_TSK")$$END$
		$END$
		$IF LENGTH(CHECK_FUNC_NONNULL) && (task == 0)$
			$ERROR TSK.TEXT_LINE[tskid]$E_PAR: 
				$FORMAT(_("%1% `%2%\' of `%3%\' in %4% is null"),
				"task", TSK.TASK[tskid], tskid, "CRE_TSK")$$END$
		$END$
		$texrtn = PEEK(tinib + offsetof_TINIB_texrtn, sizeof_FP)$
		$IF LENGTH(CHECK_FUNC_ALIGN) && (texrtn & (CHECK_FUNC_ALIGN - 1))$
			$ERROR DEF_TEX.TEXT_LINE[tskid]$E_PAR: 
				$FORMAT(_("%1% `%2%\' of `%3%\' in %4% is not aligned"),
				"texrtn", TSK.TEXRTN[tskid], tskid, "DEF_TEX")$$END$
		$END$
		$tinib = tinib + sizeof_TINIB$
	$END$

$END$

$ 
$  スタック領域の先頭番地のチェック
$ 
$IF LENGTH(CHECK_STACK_ALIGN) || LENGTH(CHECK_STACK_NONNULL)$
$	// 非タスクコンテキスト用のスタック領域の先頭番地のチェック
	$istk = PEEK(SYMBOL("_kernel_istk"), sizeof_void_ptr)$
	$IF LENGTH(CHECK_STACK_ALIGN) && (istk & (CHECK_STACK_ALIGN - 1))$
		$ERROR ICE.TEXT_LINE[1]$E_PAR: 
			$FORMAT(_("%1% `%2%\' in %3% is not aligned"),
			"istk", ICS.ISTK[1], "DEF_ICS")$$END$
	$END$
	$IF LENGTH(CHECK_STACK_NONNULL) && (istk == 0)$
		$ERROR ICE.TEXT_LINE[1]$E_PAR: 
			$FORMAT(_("%1% `%2%\' in %3% is null"),
			"istk", ICS.ISTK[1], "DEF_ICS")$$END$
	$END$
$END$
