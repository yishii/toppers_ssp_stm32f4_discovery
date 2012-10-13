/*
 *  TOPPERS/SSP Kernel
 *      Smallest Set Profile Kernel
 * 
 *  Copyright (C) 2000-2003 by Embedded and Real-Time Systems Laboratory
 *                              Toyohashi Univ. of Technology, JAPAN
 *  Copyright (C) 2005-2007 by Embedded and Real-Time Systems Laboratory
 *              Graduate School of Information Science, Nagoya Univ., JAPAN
 *
 *  Ported to STM32F4(-discovery) by Yasuhiro ISHII 2012
 *  Email : ishii.yasuhiro@gmail.com
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
 * ターゲット依存モジュール（CQ-STARM用）
 */
#include "kernel_impl.h"
#include <sil.h>
#include "cq_starm.h"
#include "target_serial.h"
#include "target_syssvc.h"



/* GPIO port mode register
   00b : Input
   01b : General purpose output mode
   10b : Alternate function mode
   11b : Analog mode
*/
Inline void set_port_mode(uint32_t reg,uint_t p,int_t v)
{
  sil_andw((void*)GPIO_MODER(reg),~(uint32_t)((0x03L << (p << 1))));
  sil_orw((void*)GPIO_MODER(reg),((uint32_t)(v & 0x03) << (p << 1)));
}

/* GPIO port output speed register
   00b :   2MHz
   01b :  25MHz
   10b :  50MHz
   11b : 100MHz
*/
Inline void set_port_speed(uint32_t reg,uint_t p,int_t v)
{
  sil_andw((void*)GPIO_OSPEEDR(reg),~(0x03L << (p << 1)));
  sil_orw((void*)GPIO_OSPEEDR(reg),((uint32_t)(v & 0x03) << (p << 1)));
}

/* GPIO port input data register
 */
Inline int_t get_port_data(uint32_t reg,uint_t p)
{
  return(!!(sil_rew_mem((void*)GPIO_IDR(reg)) & (1 << p)));
}

/* GPIO port output data register
*/
Inline void set_port_data(uint32_t reg,uint_t p,int_t v)
{
  sil_andw((void*)GPIO_ODR(reg),~(1L << p));
  sil_orw((void*)GPIO_ODR(reg),(v & 0x01) << p);
}


/* GPIO alternate function
 */
Inline void select_alternate_port_function(uint32_t reg,uint_t p,int_t v)
{
  if (p < 8){
    sil_andw((void*)GPIO_AFRL(reg),~(0x0FL << (p << 2)));
    sil_orw((void*)GPIO_AFRL(reg),((uint32_t)(v & 0x0f) << (p << 2)));
  } else {
    p -= 8;
    sil_andw((void*)GPIO_AFRH(reg),~(0x0FL << (p << 2)));
    sil_orw((void*)GPIO_AFRH(reg),((uint32_t)(v & 0x0f) << (p << 2)));
  }
}

/*
 * ターゲット依存部　初期化処理
 */
void target_initialize(void)
{

  sil_orw((void*)RCC_CR, CR_HSI_ON);
  
  // Reset CFGR Register : yishii
  sil_wrw_mem((void*)RCC_CFGR,0L);
  
  // Reset HSEON,CSSON and PLLON bits : yishii
  sil_andw((void*)RCC_CR,0xfef6ffff);
  
  sil_wrw_mem((void*)RCC_PLLCFGR,0x24003010);
  
  // reset HSEBYP bit
  sil_andw((void*)RCC_CR,0xfffbffff);
  
  sil_wrw_mem((void*)RCC_CIR,0L);
  
  ///////////////////////////////////////////////////////////////
  // SetSysClock
  
  // Enable HSE
  sil_orw((void*)RCC_CR, CR_HSE_ON);
  
  while ((sil_rew_mem((void*)RCC_CR) & CR_HSE_RDY) == 0);

  sil_orw((void*)RCC_APB1ENR,0x10000000); // APB1ENR.PWREN = set
  sil_orw((void*)PWR_CR,PWR_CR_VOS);

  // HCLK = SYSCLK / 1
  sil_orw((void*)RCC_CFGR,0);

  // PCLK2 = HCLK / 2
  sil_orw((void*)RCC_CFGR,0x00008000);

  // PCLK1 = HCLK / 4
  sil_orw((void*)RCC_CFGR,0x00001400);

  // Configure the main PLL

#define PLL_M      8
#define PLL_N    336
#define PLL_P      2
#define RCC_PLLCFGR_PLLSRC_HSE              ((uint32_t)0x00400000)
#define PLL_Q      7

  sil_wrw_mem((void*)RCC_PLLCFGR,
	      PLL_M | (PLL_N << 6) | (((PLL_P >> 1) -1) << 16) |
	      (RCC_PLLCFGR_PLLSRC_HSE) | (PLL_Q << 24));

  sil_orw((void*)RCC_CR,CR_PLL_ON);

  // wait for PLL Ready
  while ((sil_rew_mem((void*)RCC_CR) & CR_PLL_RDY) == 0);

  /* Configure Flash prefetch, Instruction cache, Data cache and wait state */
  sil_wrw_mem((void*)FLASH_ACR,FLASH_ACR_PRFTEN | FLASH_ACR_ICEN | FLASH_ACR_DCEN | FLASH_ACR_LATENCY_5WS);

  // Select the main PLL as system clock source
  sil_andw((void*)RCC_CFGR,(uint32_t)~CFGR_SW_MASK);
  sil_orw((void*)RCC_CFGR,CFGR_SW_PLL);


	// AHB1 GPIO Clock enable for STM32F4
	sil_orw((void*)RCC_AHB1ENR,0x000001FF);

	//  all enable(tmp)
	sil_orw((void*)RCC_APB1ENR,0x36fec9ff);

	// APB2 USART1 Clock enable for STM32F4
	sil_orw((void*)RCC_APB2ENR,0x00000010);

	// all enable(tmp)
	sil_orw((void*)RCC_APB2ENR,0x00075f33);


	/*
	 *  プロセッサ依存部の初期化
	 */
	prc_initialize();
	/*
	 *  I/Oポートの初期化
	 */



	/* USART1 @ USART1_REMAP = 0
	   TX : PA9
	   RX : PA10
	*/

	/* USART1(RX) */
	//set_port_mode(GPIOA_BASE,10,2);
	set_port_mode(GPIOB_BASE,7,2); // test!!


	/* USART1(TX) */
	//set_port_speed(GPIOA_BASE,9,MODE_OUTPUT_50MHZ);
	//set_port_mode(GPIOA_BASE,9,2);

	set_port_speed(GPIOB_BASE,6,MODE_OUTPUT_50MHZ);
	set_port_mode(GPIOB_BASE,6,2);

	/* select alternate pin function */
	//select_alternate_port_function(GPIOA_BASE,9,7);
	//select_alternate_port_function(GPIOA_BASE,10,7);
	select_alternate_port_function(GPIOB_BASE,7,7);
	select_alternate_port_function(GPIOB_BASE,6,7);
	/* LEDポート */

	// for STM32F4-discovery

	set_port_speed(GPIOD_BASE,12,MODE_OUTPUT_50MHZ);
	set_port_speed(GPIOD_BASE,13,MODE_OUTPUT_50MHZ);
	set_port_speed(GPIOD_BASE,14,MODE_OUTPUT_50MHZ);
	set_port_speed(GPIOD_BASE,15,MODE_OUTPUT_50MHZ);

	// LED(ORANGE)
	set_port_mode(GPIOD_BASE,13,1);
	set_port_data(GPIOD_BASE,13,1); // for debug
	// LED(GREEN)
	set_port_mode(GPIOD_BASE,12,1);
	set_port_data(GPIOD_BASE,12,1); // for debug
	// LED(RED)
	set_port_mode(GPIOD_BASE,14,1);
	set_port_data(GPIOD_BASE,14,1); // for debug
	// LED(BLUE)
	set_port_mode(GPIOD_BASE,15,1);
	set_port_data(GPIOD_BASE,15,1); // for debug

	/*
	 *  バナー出力用のシリアル初期化
	 */
	target_low_output_init(SIO_PORTID);

}

/*
 * ターゲット依存部 終了処理
 */
void target_exit(void)
{
	/* プロセッサ依存部の終了処理 */
	prc_terminate();
	
	while(true)
		;
}

/*
 * システムログの低レベル出力のための文字出力
 */
void target_fput_log(char_t c)
{
	if (c == '\n') {
		sio_pol_snd_chr('\r', SIO_PORTID);
	}
	sio_pol_snd_chr(c, SIO_PORTID);
}
