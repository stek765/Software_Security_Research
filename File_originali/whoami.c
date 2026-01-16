/* whoami_clean.c - Versione semplificata per Tigress */
#include <stdio.h>
#include <unistd.h>
#include <pwd.h>
#include <sys/types.h>

int main(int argc, char **argv) {
    /* Ottiene l'Effective User ID (EUID) del processo corrente */
    uid_t uid = geteuid();
    
    /* Cerca il nome utente nel database delle password usando l'ID */
    struct passwd *pw = getpwuid(uid);
    
    if (pw) {
        /* Stampa il nome utente */
        printf("%s\n", pw->pw_name);
        return 0;
    }
    
    return 1;
}