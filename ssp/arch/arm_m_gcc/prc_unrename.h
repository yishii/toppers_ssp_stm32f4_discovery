/* This file is generated from prc_rename.def by genrename. */

/* This file is included only when prc_rename.h has been included. */
#ifdef TOPPERS_PRC_RENAME_H
#undef TOPPERS_PRC_RENAME_H

/*
 *  prc_config.c
 */
#undef exc_tbl
#undef vector_table
#undef lock_flag
#undef saved_iipm
#undef intnest
#undef default_exc_handler
#undef default_int_handler
#undef x_config_int
#undef x_clear_int
#undef prc_initialize
#undef prc_terminate
#undef bitpat_cfgint

/*
 *  prc_support.S
 */
#undef int_entry
#undef exc_entry
#undef ret_int
#undef ret_exc
#undef svc_handler

#ifdef TOPPERS_LABEL_ASM

/*
 *  prc_config.c
 */
#undef _exc_tbl
#undef _vector_table
#undef _lock_flag
#undef _saved_iipm
#undef _intnest
#undef _default_exc_handler
#undef _default_int_handler
#undef _x_config_int
#undef _x_clear_int
#undef _prc_initialize
#undef _prc_terminate
#undef _bitpat_cfgint

/*
 *  prc_support.S
 */
#undef _int_entry
#undef _exc_entry
#undef _ret_int
#undef _ret_exc
#undef _svc_handler

#endif /* TOPPERS_LABEL_ASM */


#endif /* TOPPERS_PRC_RENAME_H */
