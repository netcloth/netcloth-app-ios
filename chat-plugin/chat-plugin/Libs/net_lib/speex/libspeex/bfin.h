
#if __GNUC__ <= 3
# define BFIN_HWLOOP0_REGS
# define BFIN_HWLOOP1_REGS
#else
# define BFIN_HWLOOP0_REGS , "LB0", "LT0", "LC0"
# define BFIN_HWLOOP1_REGS , "LB1", "LT1", "LC1"
#endif
