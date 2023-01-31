#import <dlfcn.h>
#import <stdio.h>
#import <unistd.h>

#define CS_OPS_STATUS 0 /* OK */
#define CS_DEBUGGED 0x10000000 /* process is or has been debugged */
extern int csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize);

int isDebugged(void)
{
  int flags;
  int retval = csops(getpid(), CS_OPS_STATUS, &flags, sizeof(flags));
  return retval == 0 && flags & CS_DEBUGGED;
}
