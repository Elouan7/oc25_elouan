# 📊 TP 2 : Analyse de Benchmarks Complémentaires (Exercice 2.3)

### 1. Sélection de benchmarks variés
Pour évaluer les capacités des LLM au-delà de la culture générale (MMLU), nous avons sélectionné trois benchmarks testant des compétences spécifiques : la logique mathématique, la programmation et les sciences de haut niveau.

### 2. Tableau comparatif des benchmarks

| Benchmark | Créateur (Année) | Domaine | Type de compétence mesurée |
| :--- | :--- | :--- | :--- |
| **GSM8K** | OpenAI (2021) | Mathématiques (Collège) | Raisonnement multi-étapes (*Chain-of-Thought*). |
| **HumanEval** | OpenAI (2021) | Programmation (Python) | Capacité à transformer une intention en code fonctionnel. |
| **GPQA** | NYU/Anthropic (2023) | Sciences (Doctorat) | Expertise scientifique de pointe (Physique, Bio, Chimie). |

---

### 3. Analyse des compétences mesurées

* **Raisonnement Logique (GSM8K) :** Ce benchmark ne teste pas seulement le calcul, mais la capacité de l'IA à décomposer un problème narratif en une suite d'opérations logiques sans faire d'erreur cumulative.
* **Synthèse de Code (HumanEval) :** L'IA doit comprendre des docstrings complexes et générer un algorithme qui passe des tests unitaires. Cela mesure la précision syntaxique et la logique algorithmique.
* **Expertise de "Niche" (GPQA) :** Ce test est conçu pour être extrêmement difficile, même pour des humains experts. Il mesure si l'IA peut aider sur des sujets de recherche pointus sans "halluciner".

---

### 4. Comparaison des performances : Modèles Locaux vs Géants

> **Exemple de question type (GSM8K) :**
> *"Léa a 20 € . Elle achète 2 livres à 7 € chacun. Combien lui reste-t-il ?"*

* **Modèles Locaux (ex: SmolLM2-1.7B, TinyLlama) :**
    * **Impression :** Ils réussissent les calculs simples mais échouent souvent dès que le problème dépasse 3 ou 4 étapes de raisonnement. Ils ont tendance à "oublier" une partie de l'énoncé en cours de route.
    * **Suivi d'instructions :** Moyen. Ils peuvent parfois répondre avec du texte superflu malgré la consigne "Répondre par un chiffre uniquement".

* **Grands Modèles (ex: Gemini 1.5 Pro, GPT-4) :**
    * **Impression :** Quasi-parfaits sur le niveau collège/lycée. Ils utilisent naturellement le *Chain-of-Thought* pour structurer leur pensée.
    * **Suivi d'instructions :** Très rigoureux.

---

### 5. Évolution des scores (État de l'art)

L'évolution des performances montre que certains benchmarks deviennent "obsolètes" car les modèles atteignent désormais les scores maximaux.

1.  **GSM8K :** À sa sortie, les modèles plafonnaient à 35%. En 2026, les meilleurs modèles dépassent **95%**, rendant ce test trop facile pour les nouveaux fleurons.
2.  **HumanEval :** Les scores sont passés de ~30% (GPT-3) à plus de **90%** pour les modèles spécialisés dans le code.
3.  **GPQA :** C'est le nouveau juge de paix. Alors que les humains non-experts obtiennent environ 34% de bonnes réponses, les meilleurs modèles actuels ont grimpé de 30% à près de **75%** en seulement deux ans.
