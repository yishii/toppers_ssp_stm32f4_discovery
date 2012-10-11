/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2006-2008 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *  Copyright (C) 2010-2012 by Meika Sugimoto
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
 */

/*
 *		シリアルインタフェースドライバ
 */

#include <kernel.h>
#include "target_syssvc.h"
#include "target_serial.h"
#include "serial.h"
#include "kernel_cfg.h"

/*
 *  バッファサイズのデフォルト値とバッファの定義
 */
#ifndef SERIAL_RCV_BUFSZ1
#define	SERIAL_RCV_BUFSZ1	64			/* ポート1の受信バッファサイズ */
#endif /* SERIAL_RCV_BUFSZ1 */

#ifndef SERIAL_SND_BUFSZ1
#define	SERIAL_SND_BUFSZ1	64			/* ポート1の送信バッファサイズ */
#endif /* SERIAL_SND_BUFSZ1 */

static char_t	rcv_buffer1[SERIAL_RCV_BUFSZ1];
static char_t	snd_buffer1[SERIAL_SND_BUFSZ1];

#if TNUM_PORT >= 2						/* ポート2に関する定義 */

#ifndef SERIAL_RCV_BUFSZ2
#define	SERIAL_RCV_BUFSZ2	64			/* ポート2の受信バッファサイズ */
#endif /* SERIAL_RCV_BUFSZ2 */

#ifndef SERIAL_SND_BUFSZ2
#define	SERIAL_SND_BUFSZ2	64			/* ポート2の送信バッファサイズ */
#endif /* SERIAL_SND_BUFSZ2 */

static char_t	rcv_buffer2[SERIAL_RCV_BUFSZ2];
static char_t	snd_buffer2[SERIAL_SND_BUFSZ2];

#endif /* TNUM_PORT >= 2 */

#if TNUM_PORT >= 3						/* ポート3に関する定義 */

#ifndef SERIAL_RCV_BUFSZ3
#define	SERIAL_RCV_BUFSZ3	64			/* ポート3の受信バッファサイズ */
#endif /* SERIAL_RCV_BUFSZ3 */

#ifndef SERIAL_SND_BUFSZ3
#define	SERIAL_SND_BUFSZ3	64			/* ポート3の送信バッファサイズ */
#endif /* SERIAL_SND_BUFSZ3 */

static char_t	rcv_buffer3[SERIAL_RCV_BUFSZ3];
static char_t	snd_buffer3[SERIAL_SND_BUFSZ3];

#endif /* TNUM_PORT >= 3 */

/*
 *  シリアルポート初期化ブロック
 */
typedef struct serial_port_initialization_block {
	uint_t	rcv_bufsz;		/* 受信バッファサイズ */
	char_t	*rcv_buffer;	/* 受信バッファ */
	uint_t	snd_bufsz;		/* 送信バッファサイズ */
	char_t	*snd_buffer;	/* 送信バッファ */
} SPINIB;

static const SPINIB spinib_table[TNUM_PORT] = {
	{ SERIAL_RCV_BUFSZ1, rcv_buffer1,
	  SERIAL_SND_BUFSZ1, snd_buffer1 },
#if TNUM_PORT >= 2
	{ SERIAL_RCV_BUFSZ2, rcv_buffer2,
	  SERIAL_SND_BUFSZ2, snd_buffer2 },
#endif /* TNUM_PORT >= 2 */
#if TNUM_PORT >= 3
	{ SERIAL_RCV_BUFSZ3, rcv_buffer3,
	  SERIAL_SND_BUFSZ3, snd_buffer3 },
#endif /* TNUM_PORT >= 3 */
};

/*
 *  シリアルポート管理ブロック
 */
typedef struct serial_port_control_block {
	const SPINIB *p_spinib;		/* シリアルポート初期化ブロック */
	SIOPCB	*p_siopcb;			/* シリアルI/Oポート管理ブロック */
	bool_t	openflag;			/* オープン済みフラグ */
	bool_t	errorflag;			/* エラーフラグ */
	uint_t	ioctl;				/* 動作制御の設定値 */

	uint_t	rcv_read_ptr;		/* 受信バッファ読出しポインタ */
	uint_t	rcv_write_ptr;		/* 受信バッファ書込みポインタ */
	uint_t	rcv_count;			/* 受信バッファ中の文字数 */

	uint_t	snd_read_ptr;		/* 送信バッファ読出しポインタ */
	uint_t	snd_write_ptr;		/* 送信バッファ書込みポインタ */
	uint_t	snd_count;			/* 送信バッファ中の文字数 */
} SPCB;

static SPCB	spcb_table[TNUM_PORT];

/*
 *  シリアルポートIDからシリアルポート管理ブロックを取り出すためのマクロ
 */
#define INDEX_PORT(portid)	((uint_t)((portid) - 1))
#define get_spcb(portid)	(&(spcb_table[INDEX_PORT(portid)]))

/*
 *  ポインタのインクリメント
 */
#define INC_PTR(ptr, bufsz)		{ if (++(ptr) == (bufsz)) { (ptr) = 0; }}

/*
 *  サービスコール呼出しマクロ
 *
 *  サービスコール呼出しを含む式expを評価し，返値がエラー（負の値）の場
 *  合には，ercにercd_expを評価した値を代入し，error_exitにgotoする．
 */
#define SVC(exp, ercd_exp) \
				{ if ((exp) < 0) { ercd = (ercd_exp); goto error_exit; }}

/*
 *  E_SYSエラーの生成
 */
static ER
gen_ercd_sys(SPCB *p_spcb)
{
	p_spcb->errorflag = true;
	return(E_SYS);
}


/*
 *  シリアルインタフェースドライバの初期化ルーチン
 */
void
serial_initialize(intptr_t exinf)
{
	uint_t	i;
	SPCB	*p_spcb;

	for (p_spcb = spcb_table, i = 0; i < TNUM_PORT; p_spcb++, i++) {
		p_spcb->p_spinib = &(spinib_table[i]);
		p_spcb->openflag = false;
	}
}

/*
 *  シリアルインターフェースドライバの終了ルーチン
 */

void
serial_terminate(intptr_t exinf)
{
	uint_t	i;
	SPCB	*p_spcb;
	
	/* バッファに残っている全ての文字を出力する */
	for (p_spcb = spcb_table, i = 0; i < TNUM_PORT; p_spcb++, i++) {
		while(p_spcb->snd_count != 0)
		{
			if(sio_snd_chr(p_spcb->p_siopcb,
					p_spcb->p_spinib->snd_buffer[p_spcb->snd_read_ptr]) == true)
			{
				INC_PTR(p_spcb->snd_read_ptr, p_spcb->p_spinib->snd_bufsz);
				p_spcb->snd_count--;
			}
		}
	}

}

/*
 *  シリアルポートのオープン（サービスコール）
 */
ER
serial_opn_por(ID portid)
{
	SPCB	*p_spcb;
	ER		ercd;

	if (sns_dpn()) {				/* コンテキストのチェック */
		return(E_CTX);
	}
	if (!(1 <= portid && portid <= TNUM_PORT)) {
		return(E_ID);				/* ポート番号のチェック */
	}
	p_spcb = get_spcb(portid);

	SVC(dis_dsp(), gen_ercd_sys(p_spcb));
	if (p_spcb->openflag) {			/* オープン済みかのチェック */
		ercd = E_OBJ;
	}
	else {
		/*
		 *  変数の初期化
		 */
		p_spcb->ioctl = (IOCTL_ECHO | IOCTL_CRLF);

		p_spcb->rcv_read_ptr = p_spcb->rcv_write_ptr = 0U;
		p_spcb->rcv_count = 0U;

		p_spcb->snd_read_ptr = p_spcb->snd_write_ptr = 0U;
		p_spcb->snd_count = 0U;

		/*
		 *  これ以降，割込みを禁止する．
		 */
		if (loc_cpu() < 0) {
			ercd = E_SYS;
			goto error_exit_enadsp;
		}

		/*
		 *  ハードウェア依存のオープン処理
		 */
		p_spcb->p_siopcb = sio_opn_por(portid, (intptr_t) p_spcb);

		/*
		 *  受信通知コールバックを許可する．
		 */
		sio_ena_cbr(p_spcb->p_siopcb, SIO_RDY_RCV);
		p_spcb->openflag = true;
		p_spcb->errorflag = false;

		if (unl_cpu() < 0) {
			p_spcb->errorflag = true;
			ercd = E_SYS;
			goto error_exit_enadsp;
		}
		ercd = E_OK;
	}

  error_exit_enadsp:
	SVC(ena_dsp(), gen_ercd_sys(p_spcb));

  error_exit:
	return(ercd);
}

/*
 *  シリアルポートのクローズ（サービスコール）
 */
ER
serial_cls_por(ID portid)
{
	SPCB	*p_spcb;
	ER		ercd;
	bool_t	eflag = false;

	if (sns_dpn()) {				/* コンテキストのチェック */
		return(E_CTX);
	}
	if (!(1 <= portid && portid <= TNUM_PORT)) {
		return(E_ID);				/* ポート番号のチェック */
	}
	p_spcb = get_spcb(portid);

	SVC(dis_dsp(), gen_ercd_sys(p_spcb));
	if (!(p_spcb->openflag)) {		/* オープン済みかのチェック */
		ercd = E_OBJ;
	}
	else {
		/*
		 *  ハードウェア依存のクローズ処理
		 */
		if (loc_cpu() < 0) {
			eflag = true;
		}
		sio_cls_por(p_spcb->p_siopcb);
		p_spcb->openflag = false;
		if (unl_cpu() < 0) {
			eflag = true;
		}
		
		/*
		 *  エラーコードの設定
		 */
		if (eflag) {
			ercd = gen_ercd_sys(p_spcb);
		}
		else {
			ercd = E_OK;
		}
	}
	SVC(ena_dsp(), gen_ercd_sys(p_spcb));

  error_exit:
	return(ercd);
}

/*
 *  シリアルポートへの文字送信
 *
 *  p_spcbで指定されるシリアルI/Oポートに対して，文字cを送信する．文字
 *  を送信レジスタにいれた場合にはtrueを返す．そうでない場合には，送信
 *  レジスタが空いたことを通知するコールバック関数を許可し，falseを返す．
 *  この関数は，CPUロック状態で呼び出される．
 */
Inline bool_t
serial_snd_chr(SPCB *p_spcb, char_t c)
{
	if (sio_snd_chr(p_spcb->p_siopcb, c)) {
		return(true);
	}
	else {
		sio_ena_cbr(p_spcb->p_siopcb, SIO_RDY_SND);
		return(false);
	}
}

/*
 *  シリアルポートへの1文字送信
 */
static ER_BOOL
serial_wri_chr(SPCB *p_spcb, char_t c)
{
	bool_t	buffer_full;
	ER		ercd, rercd;

	/*
	 *  LFの前にCRを送信する．
	 */
	if (c == '\n' && (p_spcb->ioctl & IOCTL_CRLF) != 0U) {
		SVC(rercd = serial_wri_chr(p_spcb, '\r'), rercd);
	}

	SVC(loc_cpu(), gen_ercd_sys(p_spcb));
	if ((p_spcb->snd_count == 0U) && serial_snd_chr(p_spcb, c)) {
		/*
		 *  シリアルI/Oデバイスの送信レジスタに文字を入れることに成功し
		 *  た場合．
		 */
		buffer_full = false;
	}
	else {
		/*
		 *  送信バッファに文字を入れる．
		 */
		p_spcb->p_spinib->snd_buffer[p_spcb->snd_write_ptr] = c;
		INC_PTR(p_spcb->snd_write_ptr, p_spcb->p_spinib->snd_bufsz);
		p_spcb->snd_count++;
		buffer_full = (p_spcb->snd_count == p_spcb->p_spinib->snd_bufsz);
	}

	SVC(unl_cpu(), gen_ercd_sys(p_spcb));
	ercd = (ER_BOOL) buffer_full;

  error_exit:
	return(ercd);
}

bool_t
serial_sndbuf_full(SPCB *p_spcb)
{
	return (p_spcb->snd_count == p_spcb->p_spinib->snd_bufsz);
}

bool_t
serial_rcvbuf_empty(SPCB *p_spcb)
{
	return (p_spcb->rcv_count == 0u);
}

/*
 *  シリアルポートへの文字列送信（サービスコール）
 */
ER_UINT
serial_wri_dat(ID portid, const char_t *buf, uint_t len)
{
	SPCB	*p_spcb;
	uint_t	wricnt = 0U;
	ER		ercd, rercd;

	if (sns_dpn()) {				/* コンテキストのチェック */
		return(E_CTX);
	}
	if (!(1 <= portid && portid <= TNUM_PORT)) {
		return(E_ID);				/* ポート番号のチェック */
	}

	p_spcb = get_spcb(portid);
	if (!(p_spcb->openflag)) {		/* オープン済みかのチェック */
		return(E_OBJ);
	}
	if (p_spcb->errorflag) {		/* エラー状態かのチェック */
		return(E_SYS);
	}
	
	SVC((rercd = loc_cpu()) , rercd);
	if(!serial_sndbuf_full(p_spcb))
	{
		while(wricnt < len)
		{
			SVC(rercd = serial_wri_chr(p_spcb, *buf++), rercd);
			wricnt++;
		}
	}
	SVC((rercd = unl_cpu()) , rercd);
	
  error_exit:
	return(wricnt > 0U ? (ER_UINT) wricnt : rercd);
}

/*
 *  シリアルポートからの1文字受信
 */
static bool_t
serial_rea_chr(SPCB *p_spcb, char_t *p_c)
{
	bool_t	buffer_empty;
	ER		ercd;

	SVC(loc_cpu(), gen_ercd_sys(p_spcb));

	/*
	 *  受信バッファから文字を取り出す．
	 */
	*p_c = p_spcb->p_spinib->rcv_buffer[p_spcb->rcv_read_ptr];
	INC_PTR(p_spcb->rcv_read_ptr, p_spcb->p_spinib->rcv_bufsz);
	p_spcb->rcv_count--;
	buffer_empty = (p_spcb->rcv_count == 0U);
	
	SVC(unl_cpu(), gen_ercd_sys(p_spcb));
	ercd = (ER_BOOL) buffer_empty;

  error_exit:
	return(ercd);
}

/*
 *  シリアルポートからの文字列受信（サービスコール）
 */
ER_UINT
serial_rea_dat(ID portid, char_t *buf, uint_t len)
{
	SPCB	*p_spcb;
	uint_t	reacnt = 0U;
	char_t	c = '\0';		/* コンパイラの警告を抑止するために初期化する */
	ER		ercd, rercd;
	bool_t	buffer_empty;

	if (sns_dpn()) {				/* コンテキストのチェック */
		return(E_CTX);
	}
	if (!(1 <= portid && portid <= TNUM_PORT)) {
		return(E_ID);				/* ポート番号のチェック */
	}

	p_spcb = get_spcb(portid);
	if (!(p_spcb->openflag)) {		/* オープン済みかのチェック */
		return(E_OBJ);
	}
	if (p_spcb->errorflag) {		/* エラー状態かのチェック */
		return(E_SYS);
	}
	
	buffer_empty = false;
	if(p_spcb->rcv_count >= len) {
		
		while(reacnt < len)
		{
			(void)serial_rea_chr(p_spcb, &c);
			/*
			 *  エコーバック処理．
			 */
			if ((p_spcb->ioctl & IOCTL_ECHO) != 0U) {
				SVC(rercd = serial_wri_chr(p_spcb, c), rercd);
			}
			*buf++ = c;
			reacnt++;
		}
	}
	
	ercd = reacnt;
  error_exit:
	return(reacnt > 0U ? (ER_UINT) reacnt : ercd);
}

/*
 *  シリアルポートの制御（サービスコール）
 */
ER
serial_ctl_por(ID portid, uint_t ioctl)
{
	SPCB	*p_spcb;

	if (sns_dpn()) {				/* コンテキストのチェック */
		return(E_CTX);
	}
	if (!(1 <= portid && portid <= TNUM_PORT)) {
		return(E_ID);				/* ポート番号のチェック */
	}

	p_spcb = get_spcb(portid);
	if (!(p_spcb->openflag)) {		/* オープン済みかのチェック */
		return(E_OBJ);
	}
	if (p_spcb->errorflag) {		/* エラー状態かのチェック */
		return(E_SYS);
	}

	p_spcb->ioctl = ioctl;
	return(E_OK);
}

/*
 *  シリアルポートからの送信可能コールバック
 */
void
sio_irdy_snd(intptr_t exinf)
{
	SPCB	*p_spcb;

	p_spcb = (SPCB *) exinf;

	if (p_spcb->snd_count > 0U) {
		/*
		 *  送信バッファ中から文字を取り出して送信する．
		 */
		(void) sio_snd_chr(p_spcb->p_siopcb,
					p_spcb->p_spinib->snd_buffer[p_spcb->snd_read_ptr]);
		INC_PTR(p_spcb->snd_read_ptr, p_spcb->p_spinib->snd_bufsz);
		p_spcb->snd_count--;
	}
	else {
		/*
		 *  送信すべき文字がない場合は，送信可能コールバックを禁止する．
		 */
		sio_dis_cbr(p_spcb->p_siopcb, SIO_RDY_SND);
	}
}

/*
 *  シリアルポートからの受信通知コールバック
 */
void
sio_irdy_rcv(intptr_t exinf)
{
	SPCB	*p_spcb;
	char_t	c;
	
	p_spcb = (SPCB *) exinf;
	c = (char_t) sio_rcv_chr(p_spcb->p_siopcb);
	
	if (p_spcb->rcv_count != p_spcb->p_spinib->rcv_bufsz) {
		/*
		 *  受信した文字を受信バッファに入れる．
		 *  バッファフルの場合，受信した文字を捨てる．
		 */
		p_spcb->p_spinib->rcv_buffer[p_spcb->rcv_write_ptr] = c;
		INC_PTR(p_spcb->rcv_write_ptr, p_spcb->p_spinib->rcv_bufsz);
		p_spcb->rcv_count++;
	}
}

/*
 *  シリアルインタフェースドライバからの未送信文字の取出し
 */
bool_t
serial_get_chr(ID portid, char_t *p_c)
{
	SPCB	*p_spcb;

	if (1 <= portid && portid <= TNUM_PORT) {	/* ポート番号のチェック */
		p_spcb = get_spcb(portid);
		if (p_spcb->openflag) {					/* オープン済みかのチェック */
			if (p_spcb->snd_count > 0U) {
				*p_c = p_spcb->p_spinib->snd_buffer[p_spcb->snd_read_ptr];
				INC_PTR(p_spcb->snd_read_ptr, p_spcb->p_spinib->snd_bufsz);
				p_spcb->snd_count--;
				return(true);
			}
		}
	}
	return(false);
}
