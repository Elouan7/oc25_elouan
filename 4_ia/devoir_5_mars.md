# Lecture 2 – Measuring Massive Multitask Language Understanding (MMLU)

Article étudié : *Measuring Massive Multitask Language Understanding* (2020)

---

## 1. Quelle compétence le benchmark MMLU mesure-t-il ?

Le benchmark MMLU mesure la capacité d’un modèle de langage à comprendre et mobiliser des connaissances dans un grand nombre de domaines académiques différents.

Ce qui est intéressant, c’est que ce benchmark ne teste pas seulement de la mémoire. Il évalue aussi :

- La compréhension globale
- Le raisonnement
- La capacité à généraliser sans entraînement spécifique (zero-shot / few-shot)
- La solidité des connaissances dans 57 matières différentes

Les questions sont à choix multiples et couvrent des domaines allant des mathématiques à la médecine, en passant par le droit ou l’histoire.

Selon moi, MMLU cherche donc à répondre à une question centrale :  
> Un modèle de langage peut-il réellement comprendre des sujets variés comme un étudiant humain ?

---

## 2. Quelles étaient les performances des meilleurs modèles lors de la publication ?

Lors de la publication en 2020 :

- GPT-3 obtenait environ 43 % de bonnes réponses en zero-shot.
- En few-shot, il atteignait environ 57 %.
- Les humains experts dépassaient généralement 85–90 %.

Ces résultats montrent que les modèles étaient déjà impressionnants pour leur époque, mais qu’ils restaient loin du niveau humain.

On voit aussi que les performances variaient selon les matières : certains domaines étaient mieux maîtrisés que d’autres. Cela montre que les modèles avaient des connaissances larges mais parfois superficielles.

---

## 3. Comparaison de deux questions entre trois IA

### Question 1 – Biologie

**Question :**  
Quelle est la fonction principale des mitochondries ?

A) Synthèse des protéines  
B) Production d’ATP  
C) Réplication de l’ADN  
D) Transport des lipides  

Réponse correcte : B

| IA              | Réponse | Observation |
|-----------------|----------|-------------|
| GPT-3 (2020)   | B        | Bonne réponse factuelle |
| LLM local 7B    | B        | Réponse correcte mais explication peu développée |
| GPT-4           | B        | Réponse correcte + explication claire du rôle énergétique |

On remarque que les modèles plus récents donnent non seulement la bonne réponse, mais expliquent aussi pourquoi.

---

### Question 2 – Histoire

**Question :**  
Quel événement marque le début de la Première Guerre mondiale ?

A) L’invasion de la Pologne  
B) L’assassinat de l’archiduc François-Ferdinand  
C) La révolution russe  
D) Le traité de Versailles  

Réponse correcte : B

| IA              | Réponse | Observation |
|-----------------|----------|-------------|
| GPT-3 (2020)   | B        | Correct mais justification brève |
| LLM local 7B    | Parfois erreur | Réponse moins stable |
| GPT-4           | B        | Réponse correcte + mise en contexte historique |

Cela montre que plus le modèle est avancé, plus la réponse est structurée et contextualisée.

---

## Conclusion personnelle

Le benchmark MMLU est intéressant car il permet de mesurer objectivement les progrès des modèles de langage.

En 2020, même les meilleurs modèles restaient loin du niveau humain expert. Cependant, les progrès récents montrent une amélioration rapide.

Ce benchmark met aussi en évidence une différence importante :  
avoir accès à beaucoup d’informations ne signifie pas forcément comprendre en profondeur.

---

# Traces de lecture

## IA utilisée(s)

- ChatGPT (GPT-4) pour l’analyse et la structuration
- Données chiffrées issues directement de l’article

---

## Prompts utilisés

1. "Explique la compétence mesurée par le benchmark MMLU."
2. "Quelles étaient les performances de GPT-3 dans l’article MMLU ?"
3. "Propose deux exemples de questions typiques du benchmark MMLU et compare les réponses de trois IA."

---

## Utilisation de l’IA

L’IA a été utilisée comme outil d’aide à la compréhension et à la synthèse.  
Les données numériques proviennent de l’article étudié.  
Le contenu a ensuite été reformulé et structuré pour produire cette trace de lecture.

