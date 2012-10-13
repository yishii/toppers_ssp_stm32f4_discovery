/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2007 by Embedded and Real-Time Systems Laboratory
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
 */

/*
 *  シリアルI/Oデバイス（SIO）ドライバ（CQ-STARM用）
 */

#ifndef TOPPERS_TARGET_SERIAL_H
#define TOPPERS_TARGET_SERIAL_H

#include "cq_starm.h"
#include "target_syssvc.h"

/*
 *  SIOの割込みベクタ番号
 */
#if (SIO_PORTID == 1)
#define INHNO_SIO		IRQ_VECTOR_USART1
#define INTNO_SIO		IRQ_VECTOR_USART1
#elif (SIO_PORID == 2)
#define INHNO_SIO		IRQ_VECTOR_USART2
#define INTNO_SIO		IRQ_VECTOR_USART2
#endif
#define INTPRI_SIO		-3				/* 割込み優先度 */
#define INTATR_SIO		0				/* 割込み属性 */

/*
 *  コールバックルーチンの識別番号
 */
#define SIO_RDY_SND    1U        /* 送信可能コールバック */
#define SIO_RDY_RCV    2U        /* 受信通知コールバック */

#ifndef TOPPERS_MACRO_ONLY

/*
 *  シリアルポートの管理ブロック
 */
typedef struct sio_port_control_block {
	ID port;
	uint32_t reg;
	intptr_t exinf;
} SIOPCB;

/*
 *  SIO初期化
 */
extern void sio_initialize(intptr_t exinf);

/*
 *  シリアルオープン
 */
extern SIOPCB *sio_opn_por(ID siopid, intptr_t exinf);

/*
 *  シリアルクローズ
 */
extern void sio_cls_por(SIOPCB *p_siopcb);

/*
 *  割込みハンドラ
 */
extern void sio_isr(intptr_t exinf);

/*
 *  1文字送信
 */
extern bool_t sio_snd_chr(SIOPCB *siopcb, char_t c);

/*
 *  1文字受信
 */
extern int_t sio_rcv_chr(SIOPCB *siopcb);

/*
 *  コールバックの許可
 */
extern void sio_ena_cbr(SIOPCB *siopcb, uint_t cbrtn);

/* 
 *  コールバックの禁止
 */
extern void sio_dis_cbr(SIOPCB *siopcb, uint_t cbrtn);

/*
 *  送信可能コールバック
 */
extern void sio_irdy_snd(intptr_t exinf);

/*
 *  受信通知コールバック
 */
extern void sio_irdy_rcv(intptr_t exinf);

/*
 *  1文字送信（ポーリングでの出力）
 */
extern void sio_pol_snd_chr(char_t c, ID siopid);

/*
 *  ターゲットのシリアル初期化
 */
extern void target_usart_init(ID siopid);

/*
 *  低レベル出力初期化
 */
extern void target_low_output_init(ID siopid);

#endif /* TOPPERS_MACRO_ONLY */
#endif /* TOPPERS_TARGET_SERIAL_H */
