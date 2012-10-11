/* This file is generated from prc_rename.def by genrename. */

#ifndef TOPPERS_PRC_RENAME_H
#define TOPPERS_PRC_RENAME_H

/*
 *  prc_config.c
 */
#define exc_tbl						_kernel_exc_tbl
#define vector_table				_kernel_vector_table
#define lock_flag					_kernel_lock_flag
#define saved_iipm					_kernel_saved_iipm
#define intnest						_kernel_intnest
#define default_exc_handler			_kernel_default_exc_handler
#define default_int_handler			_kernel_default_int_handler
#define x_config_int				_kernel_x_config_int
#define x_clear_int					_kernel_x_clear_int
#define prc_initialize				_kernel_prc_initialize
#define prc_terminate				_kernel_prc_terminate
#define bitpat_cfgint				_kernel_bitpat_cfgint

/*
 *  prc_support.S
 */
#define int_entry					_kernel_int_entry
#define exc_entry					_kernel_exc_entry
#define ret_int						_kernel_ret_int
#define ret_exc						_kernel_ret_exc
#define svc_handler					_kernel_svc_handler

#ifdef TOPPERS_LABEL_ASM

/*
 *  prc_config.c
 */
#define _exc_tbl					__kernel_exc_tbl
#define _vector_table				__kernel_vector_table
#define _lock_flag					__kernel_lock_flag
#define _saved_iipm					__kernel_saved_iipm
#define _intnest					__kernel_intnest
#define _default_exc_handler		__kernel_default_exc_handler
#define _default_int_handler		__kernel_default_int_handler
#define _x_config_int				__kernel_x_config_int
#define _x_clear_int				__kernel_x_clear_int
#define _prc_initialize				__kernel_prc_initialize
#define _prc_terminate				__kernel_prc_terminate
#define _bitpat_cfgint				__kernel_bitpat_cfgint

/*
 *  prc_support.S
 */
#define _int_entry					__kernel_int_entry
#define _exc_entry					__kernel_exc_entry
#define _ret_int					__kernel_ret_int
#define _ret_exc					__kernel_ret_exc
#define _svc_handler				__kernel_svc_handler

#endif /* TOPPERS_LABEL_ASM */


#endif /* TOPPERS_PRC_RENAME_H */
