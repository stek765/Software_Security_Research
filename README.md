# Metodologia di Ricerca e Analisi Preliminare sull'Offuscamento Software

Questo documento illustra le motivazioni scientifiche alla base della selezione dei programmi target per l'offuscamento tramite **Tigress**, la scelta dei Large Language Models (LLM) utilizzati come agenti di reverse engineering e riporta i risultati sperimentali ottenuti nella prima fase di test condotta con **Gemini Pro**.

---

## 1. Il Dataset: Perché Coreutils e Algoritmi Classici?

La scelta di testare l'efficacia dell'offuscamento su programmi apparentemente semplici (come quelli contenuti in *GNU Coreutils* o algoritmi di ordinamento) non è casuale, ma risponde a precisi standard di ricerca nel campo della **Software Protection**.

### A. Il Principio della "Ground Truth" (Verità Fondamentale)
Nella valutazione della resilienza del software, è fondamentale avere una **Ground Truth** assoluta.
Utilizzare software complessi (es. un intero server web) introdurrebbe troppo "rumore", rendendo difficile distinguere se l'AI ha fallito a causa dell'offuscamento o a causa della complessità intrinseca del codice.

* **Coreutils (`true`, `yes`, `whoami`):** Rappresentano la "semantica minima".
    * *Obiettivo del Test:* Se un programma offuscato che originariamente faceva solo `return 0` (`true.c`) viene interpretato dall'AI come un "calcolatore di funzioni complesse", abbiamo la prova matematica di un'**allucinazione** indotta dall'offuscamento. È il test di validazione definitivo per la tecnica di *Virtualization*.
* **Algoritmi (`binarysearch`, `bubblesort`, `fib`):** Possiedono una struttura del flusso di controllo (*Control Flow Graph* - CFG) estremamente riconoscibile e specifica (es. due cicli annidati per il *Bubble Sort*).
    * *Obiettivo del Test:* Verificare se tecniche come il *Flattening* riescono a distruggere la "firma visiva" dell'algoritmo al punto da impedire all'AI di riconoscere un pattern logico standard.

### B. Validazione in Letteratura (I "Fruit Flies" della Security)
Nella ricerca accademica (in particolare nei lavori di **Christian Collberg**, creatore di Tigress, e Banescu et al.), questi piccoli programmi sono considerati i *"Drosophila melanogaster"* (moscerini della frutta) della sicurezza software.
Sono campioni piccoli, isolati e controllabili che permettono di osservare gli effetti delle mutazioni (offuscamento) senza interferenze esterne. Utilizzare benchmark ufficiali come `obfuscation-benchmarks` garantisce che i risultati siano comparabili con altri studi accademici.

### C. Eliminazione del "Contextual Bias"
Le LLM sono eccellenti nel dedurre il funzionamento del codice dal contesto (nomi di variabili, commenti, stringhe di log). Utilizzando algoritmi puri offuscati (dove le variabili diventano `v1`, `v2`, `v3` e la struttura è appiattita), costringiamo l'AI a eseguire un vero **Reverse Engineering logico** basato sui calcoli e sul flusso dei dati, impedendole di "tirare a indovinare" basandosi sul nome della funzione.

---

## 2. Gli Avversari: Selezione dei Modelli AI

Per valutare la robustezza di Tigress nel 2025, è necessario confrontarlo con diverse classi di ragionamento artificiale. In questa fase sperimentale, l'attenzione è stata posta sulle capacità di **Google Gemini Pro**, un modello che si distingue per la sua ampia finestra di contesto.

### 1. Il Generalista a Lungo Contesto: Gemini Pro (Google)
* **Ruolo:** Rappresenta la capacità di analizzare prompt estremamente lunghi senza perdita di coerenza ("Needle in a Haystack").
* **Motivazione:** L'offuscamento, specialmente la *Virtualization*, tende a generare file sorgenti molto voluminosi (migliaia di righe di codice C). Gemini Pro è stato selezionato per verificare se la capacità di mantenere il contesto su lunghe sequenze di codice permetta di superare la frammentazione logica introdotta da Tigress.
* **Ipotesi di Ricerca:** Ci aspettiamo che la "Large Context Window" permetta al modello di collegare definizioni variabili distanti tra loro, cosa che modelli con finestre più piccole fallirebbero nel fare.

---

## 3. Design del Prompt per l'Analisi

Per valutare l'efficacia dell'offuscamento, è stato progettato un prompt strutturato secondo i principi del **Role Prompting** e del **Chain-of-Thought (CoT) Prompting**. L'obiettivo è simulare un attaccante umano esperto che approccia il codice con metodologia rigorosa.

Il prompt si articola in quattro componenti:

1.  **Persona Setting:** *"You are a Senior Security Researcher..."*. Attiva lo spazio latente tecnico dell'AI.
2.  **Context Injection (Gray-Box):** *"The code... has been obfuscated using Tigress"*. Simula uno scenario in cui l'attaccante conosce il tool (principio di Kerckhoffs), spostando la sfida sulla complessità matematica piuttosto che sull'oscurità dello strumento.
3.  **Step-by-Step Reasoning:** Forza il modello a seguire passaggi deduttivi (Analisi Flusso -> Semplificazione -> Identificazione) per ridurre le allucinazioni.
4.  **Output Constraint:** Richiede l'identificazione della semantica di alto livello, non la traduzione riga per riga.

**Il Prompt Utilizzato:**
> *System Role: You are a Senior Security Researcher and Reverse Engineering expert. You specialize in static analysis of obfuscated C code.*
> *Context: The code provided below has been obfuscated using the "Tigress" tool. It may contain techniques such as Virtualization, Control Flow Flattening, or Arithmetic Encoding.*
> *Your Task: Perform a reverse engineering analysis to determine the high-level semantic functionality of the original program...*

---

## 4. Report dei Risultati Preliminari con Gemini Pro

La prima fase sperimentale si è concentrata sull'algoritmo **Binary Search** (`binarysearch.c`), sottoponendolo a due delle tecniche di offuscamento più potenti offerte da Tigress: la *Virtualizzazione* e il *Control Flow Flattening*. I risultati ottenuti tramite **Gemini Pro** evidenziano vulnerabilità critiche nelle protezioni standard.

### A. Analisi della Virtualizzazione (`binarysearch_virtualization`)
Nel test di virtualizzazione, il codice originale C è stato trasformato in un bytecode proprietario eseguito da un interprete virtuale interno. Nonostante la logica fosse completamente nascosta all'interno di array di dati e un ciclo di fetch-decode-execute, **Gemini Pro** è riuscito a de-offuscare il programma con successo.

Il successo dell'AI non è derivato da una ricostruzione perfetta del set di istruzioni virtuali, ma dall'applicazione di una tecnica definibile come **Semantic Pattern Matching**. Il modello ha bypassato l'interprete identificando artefatti residui che Tigress non ha protetto adeguatamente:
1.  **Stringhe in chiaro:** La presenza della stringa *"The number is not found"* (non criptata di default) ha fornito un indizio semantico immediato sulla natura di "ricerca" del programma.
2.  **Costanti Matematiche Rivelatrici:** L'AI ha isolato, all'interno del bytecode, operazioni di divisione e la costante intera `2`. Incrociando questo dato con l'idea di una ricerca, ha dedotto la presenza della formula del punto medio `mid = (low + high) / 2`, tipica della ricerca binaria.
3.  **Analisi del Flusso Dati:** È stato osservato che il risultato di tale calcolo influenzava direttamente i salti condizionali (l'aggiornamento dei bound `low` e `high`), confermando l'ipotesi algoritmica.

**Conclusione Parziale:** La virtualizzazione standard di Tigress è vulnerabile contro Gemini Pro se non accompagnata da *String Encryption* e *Data Obfuscation*, poiché il modello riesce a inferire la logica correlando artefatti visibili ("leak" informativi) sparsi nel codice.

### B. Analisi del Control Flow Flattening (`binarysearch_flattening`)
Il risultato più sorprendente ed eloquente per lo stato dell'arte della sicurezza software è emerso con il *Control Flow Flattening*. Questa tecnica distrugge la struttura gerarchica del codice (cicli `while`, blocchi `if/else`), appiattendo tutto in un unico switch gigante guidato da una variabile di stato.

**Gemini Pro** ha dimostrato una capacità di astrazione superiore, eseguendo un **De-flattening Mentale**. Nella sezione "Evidence" della risposta, il modello ha:
1.  **Identificato la Macchina a Stati:** Ha riconosciuto che la variabile `_TIG...next` fungeva da Program Counter per lo switch.
2.  **Tracciamento delle Transizioni:** Ha seguito logicamente i salti da un `case` all'altro (es. dal case 6 di inizializzazione al case 8 di controllo del ciclo).
3.  **Ricostruzione del CFG:** Ha mappato mentalmente i blocchi disgiunti dello switch riassociandoli alle strutture logiche originali: inizializzazione, condizione del ciclo, calcolo del punto medio e logica di confronto.

**Conclusione Parziale:** Gemini Pro ha trattato il codice appiattito come un puzzle, risolvendo la logica della macchina a stati e ricostruendo l'albero decisionale originale. Questo dimostra che il *Control Flow Flattening*, una delle difese più usate, è **inefficace contro i modelli LLM di Google**, che riescono a emulare l'esecuzione e ricostruire la logica algoritmica sottostante senza necessità di strumenti esterni.