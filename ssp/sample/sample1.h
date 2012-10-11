/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 *
 *  Copyright (C) 2010-2012 by Meika Sugimoto
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

#ifndef TOPPERS_SAMPLE1_H
#define TOPPERS_SAMPLE1_H

/*
 *  ターゲット依存の定義
 */
#include "target_test.h"

#if TMAX_TPRI == 16

#define INIT_PRIORITY			(1)
#define ERRORTSK_PRIORITY		(6)
#define MAIN_PRIORITY			(7)
#define TASK1_PRIORITY			(8)
#define TASK2_PRIORITY			(9)
#define TASK3_PRIORITY			(10)
#define TASK3_EXEPRIORITY		(9)

#else

/* TMAX_TPRI == 8 */
#define INIT_PRIORITY			(1)
#define ERRORTSK_PRIORITY		(2)
#define MAIN_PRIORITY			(3)
#define TASK1_PRIORITY			(4)
#define TASK2_PRIORITY			(5)
#define TASK3_PRIORITY			(6)
#define TASK3_EXEPRIORITY		(5)

#endif /* TMAX_TPRI == 16 */

#ifndef LOOP_REF
#define LOOP_REF		ULONG_C(1000000)	/* 速度計測用のループ回数 */
#endif /* LOOP_REF */


#ifndef TOPPERS_MACRO_ONLY

extern void init_task(intptr_t exinf);
extern void main_task(intptr_t exinf);
extern void task(intptr_t exinf);

extern void main_task_cychdr(intptr_t exinf);
extern void cyclic_handler(intptr_t exinf);
extern void alarm_handler(intptr_t exinf);
extern void interrupt_service_routine(intptr_t exinf);


#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_SAMPLE1_H */

