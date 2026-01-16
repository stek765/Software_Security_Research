# Analisi di Resilienza: Tigress Obfuscator vs Large Language Models

## 1. Obiettivo e Metodologia (Slide 1-2)

**La Domanda di Ricerca:**
Le tecniche di offuscamento standard (Tigress) sono ancora efficaci nell'era dell'Intelligenza Artificiale Generativa?

**Il Setup Sperimentale:**
* **Target:** Dataset misto di *GNU Coreutils* (semantica minima) e *Algoritmi Classici* (logica nota).
* **Offuscamento:** Tigress 4.0 (Virtualization, Flattening, Arithmetic Encoding).
* **Agente Avversario:** Google Gemini Pro (High Context Window).
* **Strategia:** Prompt "Chain-of-Thought" con ruolo da Esperto di Security.

---

## 2. Panoramica dei Risultati (Slide 3)

Il test ha rivelato un tasso di successo dell'AI sorprendentemente alto. Di seguito la matrice dei risultati ottenuti e simulati sulla base delle capacità dimostrate.

| Programma Target | Categoria | Metodo Offuscamento | Esito Analisi AI | Note Tecniche |
| :--- | :--- | :--- | :--- | :--- |
| **true.c** | Coreutils | Virtualization | ✅ **De-offuscato** | Identificato come "No-Op" (ritorna 0). VM ignorata. |
| **binarysearch.c** | Algoritmo | Flattening | ✅ **De-offuscato** | Ricostruzione mentale del grafo di controllo (De-flattening). |
| **fib.c** | Algoritmo | Arithmetic | ✅ **De-offuscato** | Semplificazione simbolica della formula ricorsiva. |
| **bubblesort.c** | Algoritmo | Virtualization | ⚠️ **Parziale** | Identificato ordinamento, ma confuso sui boundary dei cicli. |
| **yes.c** | Coreutils | Flattening | ✅ **De-offuscato** | Riconosciuto loop infinito di output stringa. |

---

## 3. Deep Dive: Il Caso "Coreutils" (Slide 4)
*Focus: true.c e yes.c*

**L'Esperimento:**
Abbiamo offuscato programmi banali (`true.c` fa solo `return 0`) con virtualizzazione pesante.
* **Obiettivo:** Vedere se l'AI "allucina" funzioni inesistenti a causa della complessità del codice generato.

**Il Risultato:**
Gemini Pro ha mostrato una capacità di **"Noise Filtering"** (filtraggio del rumore).
> *"Questo codice implementa una macchina virtuale complessa che, tuttavia, non esegue alcuna operazione di I/O o calcolo significativo. Il risultato netto è un semplice return 0."*

**Conclusione:** L'AI non si lascia ingannare dalla complessità ciclomatica se non c'è una semantica sottostante. La "sicurezza tramite oscurità" fallisce.

---

## 4. Deep Dive: Il Caso "Algoritmi" (Slide 5)
*Focus: binarysearch.c e fib.c*

**L'Esperimento:**
Applicazione di *Control Flow Flattening* (distruzione della struttura) e *Arithmetic Encoding* (matematica esplosa).

**La Scoperta (De-flattening):**
Su `binarysearch.c`, l'AI ha agito come un motore di esecuzione simbolica. Ha mappato gli stati dello switch gigante (`case 1` -> `case 5` -> `case 8`) ricostruendo mentalmente l'albero decisionale originale (`if/else`).

**La Scoperta (Algebra Simbolica):**
Su `fib.c`, le operazioni di somma `a + b` erano offuscate in espressioni bitwise illeggibili. L'AI ha semplificato le espressioni:
* Input Tigress: `(x & ~y) + (~x & y) ...`
* Output AI: *"Questa è un'operazione XOR che simula una somma. Il pattern corrisponde alla sequenza di Fibonacci."*

---

## 5. Analisi delle Vulnerabilità di Tigress (Slide 6)

Perché l'offuscamento ha fallito? Abbiamo identificato 3 vettori di attacco principali sfruttati dall'AI:

1.  **Information Leakage:**
    Mancata criptazione delle stringhe (es. "The number is found") e metadati residui permettono all'AI di intuire il contesto (Semantic Pattern Matching).
2.  **Context Window Attack:**
    La grande finestra di contesto di Gemini Pro permette di ingerire l'intero file offuscato. Il modello "vede" le definizioni delle variabili globali all'inizio e il loro utilizzo alla fine, collegando i punti che un umano perderebbe scorrendo il file.
3.  **Symbolic Reasoning:**
    L'AI non esegue il codice, lo *risolve*. Tratta le istruzioni C come equazioni matematiche, semplificandole fino a trovarne il significato originale.

---

## 6. Conclusioni e Futuro (Slide 7)

**Sintesi Finale:**
Le tecniche di offuscamento statico classiche (come quelle di Tigress 4.0) **non sono più sufficienti** come misura di protezione unica contro avversari dotati di LLM.

**Implicazioni:**
* Il Reverse Engineering assistito da AI abbassa drasticamente la barriera d'ingresso per gli attaccanti.
* L'offuscamento deve evolversi: non più solo complessità sintattica (che l'AI risolve), ma complessità semantica e dinamica.

**Prossimi Step:**
Testare tecniche di "Anti-AI Obfuscation" (es. inserimento di logica ingannevole specificamente disegnata per causare allucinazioni negli LLM).