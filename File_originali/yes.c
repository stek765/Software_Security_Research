/* yes_clean.c - Versione semplificata per Tigress */
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    /* Se c'è un argomento (es: ./yes ciao), stampa quello all'infinito */
    if (argc > 1) {
        while (1) {
            printf("%s\n", argv[1]);
        }
    } 
    /* Altrimenti stampa 'y' all'infinito (comportamento default) */
    else {
        while (1) {
            puts("y");
        }
    }
    return 0;
}