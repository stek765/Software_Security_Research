/* pwd_clean.c - Versione semplificata per Tigress */
#include <stdio.h>
#include <unistd.h>
#include <limits.h>

/* Definiamo un buffer sicuro se PATH_MAX non è definito */
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

int main(int argc, char **argv) {
    char cwd[PATH_MAX];
    
    /* getcwd è la funzione standard POSIX per "Get Current Working Directory" */
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
        printf("%s\n", cwd);
        return 0;
    } else {
        perror("pwd error");
        return 1;
    }
}