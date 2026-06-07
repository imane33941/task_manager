# Task Manager — Application de gestion de tâches (Flutter Desktop)

Application desktop de gestion de tâches développée avec **Flutter**, suivant une **architecture hexagonale**, avec gestion d'état **Riverpod**, entités immuables **Freezed**, navigation **auto_route**, persistance locale **shared_preferences** et intégration continue **GitHub Actions** (tests + build multiplateforme).

> Projet final du cours Flutter — support de l'évaluation.
> _Auteur : à compléter_ · Dépôt : `https://github.com/imane33941/task_manager`

---

## Sommaire

1. [Aperçu](#aperçu)
2. [Stack technique](#stack-technique)
3. [Architecture hexagonale](#architecture-hexagonale)
4. [Modèle de données](#modèle-de-données)
5. [Fonctionnalités obligatoires](#fonctionnalités-obligatoires)
6. [Fonctionnalités bonus](#fonctionnalités-bonus)
7. [Démarche de développement (étape par étape)](#démarche-de-développement-étape-par-étape)
8. [Installation et lancement](#installation-et-lancement)
9. [Tests](#tests)
10. [Intégration continue (CI)](#intégration-continue-ci)
11. [Raccourcis clavier](#raccourcis-clavier)
12. [Checklist du rendu](#checklist-du-rendu)

---

## Aperçu

Task Manager permet de créer, organiser, filtrer et suivre des tâches, regroupées par projet et par statut. L'interface desktop propose :

- une **barre latérale permanente** : Accueil (tableau de bord), Toutes les tâches, Projets, Aujourd'hui, Cette semaine, Paramètres ;
- un **tableau de bord** en page d'accueil (statistiques : total, par statut, en retard, par priorité, par projet) ;
- une **vue liste** groupée par statut (À faire / En cours / Terminée) et une **vue Kanban** avec glisser-déposer ;
- un **panneau de détail/édition fixe** à droite (modèle maître-détail) ;
- le **filtrage** par statut, priorité et la **recherche** textuelle ;
- un **thème clair/sombre** persistant et des **raccourcis clavier**.

_Captures d'écran : à ajouter (`docs/` ou directement dans le README)._

---

## Stack technique

| Domaine | Choix |
|---|---|
| Framework | Flutter (desktop, cible macOS ; build CI macOS/Windows/Linux) |
| Gestion d'état | Riverpod (`flutter_riverpod` + `riverpod_annotation` / génération de code) |
| Entités immuables | Freezed (`freezed`, `json_serializable`) |
| Navigation | auto_route (sidebar permanente via `AutoTabsRouter`) |
| Persistance | `shared_preferences` + sérialisation JSON |
| Fenêtre desktop | `window_manager` |
| Tests | `flutter_test` + `mockito` |
| CI | GitHub Actions (tests + build multiplateforme + artifacts) |

### Justification des choix techniques

- **Riverpod (plutôt que Provider ou Bloc).** Choisi pour la gestion d'état car il est *compile-safe*, indépendant du `BuildContext` (l'état se lit hors arbre de widgets, ce qui simplifie la logique et les tests) et surtout **testable** grâce aux *overrides* : on peut remplacer un provider par un mock dans un `ProviderContainer`. La génération de code (`riverpod_annotation`) évite les erreurs de typage. Bloc aurait été plus verbeux pour un projet de cette taille ; le `Provider` historique est moins sûr côté typage.

- **Freezed (pour les entités).** Génère des classes **immuables** avec `copyWith`, `==`/`hashCode` et la sérialisation JSON (`fromJson`/`toJson`). L'immuabilité évite les bugs de mutation accidentelle et s'accorde parfaitement avec Riverpod (comparaison de valeurs pour les rebuilds). Écrire ces classes à la main serait long et source d'erreurs.

- **auto_route (pour la navigation).** Routage **déclaratif et typé** (les routes sont des classes, pas des chaînes). Il fournit `AutoTabsRouter`, exactement l'outil pour une **sidebar permanente** avec des onglets persistants comme l'exige le TP, tout en gardant chaque page indépendante.

- **shared_preferences (pour la persistance).** Suffisant pour le volume de données (des listes sérialisées en JSON), **multiplateforme**, sans configuration ni schéma. Une base type SQLite/Isar aurait été surdimensionnée ici ; le JSON est lisible et se marie avec le `toJson`/`fromJson` déjà fourni par Freezed.

- **window_manager (fenêtre desktop).** Permet de fixer la **taille minimale** (800×600) et le **titre** de la fenêtre — deux exigences explicites du cahier des charges pour une application desktop.

- **mockito (pour les tests).** Génère des **mocks** des interfaces de repository (`@GenerateNiceMocks`), ce qui permet d'isoler la couche domaine/application et de tester les providers sans I/O réelle — précisément les deux cas de test demandés.

- **GitHub Actions (CI/CD).** Intégré nativement à GitHub, gratuit pour le projet, et capable de lancer une **matrice multiplateforme** (macOS/Windows/Linux) pour les builds tout en publiant des artifacts téléchargeables.

---

## Architecture hexagonale

Le projet respecte une séparation stricte en couches. Le **domaine** ne dépend de personne ; l'**infrastructure** implémente les interfaces du domaine ; l'**application** orchestre via Riverpod ; la **présentation** ne connaît que l'application et le domaine.

```
lib/
├── core/                         # Utilitaires transverses, sans dépendance métier
│   ├── date_extensions.dart      # isToday, isThisWeek, isOverdue, formatted
│   └── enum_labels.dart          # libellés FR des enums (Priority, TaskStatus)
│
├── domain/                       # Cœur métier : entités + contrats (interfaces)
│   ├── entities/
│   │   ├── task.dart             # Entité Task (Freezed)
│   │   └── project.dart          # Entité Project (Freezed)
│   └── repositories/
│       ├── task_repository.dart      # Interface abstraite TaskRepository
│       └── project_repository.dart   # Interface abstraite ProjectRepository
│
├── application/                  # Use cases + état (Riverpod)
│   ├── shared_preferences_provider.dart   # Provider injecté au démarrage
│   ├── task_providers.dart                # Fournit le TaskRepository concret
│   ├── project_providers.dart             # Fournit le ProjectRepository concret
│   ├── task_list_provider.dart            # AsyncNotifier CRUD des tâches
│   ├── project_list_provider.dart         # AsyncNotifier CRUD des projets
│   ├── date_filtered_providers.dart       # Aujourd'hui / Semaine / par projet
│   ├── search_provider.dart               # Recherche + filtres statut/priorité + focus
│   ├── stats_provider.dart                # Statistiques agrégées (dashboard)
│   └── theme_provider.dart                # ThemeMode persistant
│
├── infrastructure/               # Implémentations concrètes des interfaces
│   └── repositories/
│       ├── shared_prefs_task_repository.dart      # Persistance JSON des tâches
│       ├── shared_prefs_project_repository.dart   # Persistance JSON des projets
│       ├── in_memory_task_repository.dart         # Implémentation mémoire (dev/test)
│       └── in_memory_project_repository.dart      # Implémentation mémoire (dev/test)
│
├── presentation/                 # UI : pages, widgets, router, thème
│   ├── pages/                    # dashboard, all_tasks, projects, today, week, settings, main_layout
│   ├── widgets/                  # task_tile, task_dialog, kanban_board
│   ├── router/                   # app_router (auto_route)
│   └── theme/                    # priority_colors (ThemeExtension)
│
└── main.dart                     # Point d'entrée, init fenêtre, injection des prefs
```

**Inversion de dépendance.** Le domaine définit `TaskRepository` / `ProjectRepository` (interfaces). L'infrastructure fournit `SharedPrefsTaskRepository` qui les implémente. L'application les relie via un provider :

```dart
@riverpod
TaskRepository taskRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsTaskRepository(prefs);
}
```

Pour changer de stratégie de stockage (ex. base de données), il suffit de fournir une autre implémentation de l'interface dans ce provider — aucune autre couche n'est impactée. C'est aussi ce qui rend les tests possibles : on **remplace** le repository par un mock via les overrides Riverpod.

---

## Modèle de données

Les entités sont **immuables et sérialisables**, générées avec Freezed (`copyWith`, `==`, `fromJson`/`toJson` automatiques).

### Task

| Champ | Type | Obligatoire | Défaut |
|---|---|---|---|
| `id` | String | Oui | — |
| `title` | String | Oui | — |
| `description` | String | Non | `''` |
| `priority` | `Priority` (low, medium, high, urgent) | Oui | `medium` |
| `status` | `TaskStatus` (todo, inProgress, done) | Oui | `todo` |
| `dueDate` | DateTime? | Non | `null` |
| `projectId` | String? | Non | `null` |
| `createdAt` | DateTime | Oui | — |

```dart
@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    @Default('') String description,
    @Default(Priority.medium) Priority priority,
    @Default(TaskStatus.todo) TaskStatus status,
    DateTime? dueDate,
    String? projectId,
    required DateTime createdAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

enum Priority { low, medium, high, urgent }
enum TaskStatus { todo, inProgress, done }
```

### Project

| Champ | Type | Obligatoire |
|---|---|---|
| `id` | String | Oui |
| `name` | String | Oui |
| `color` | int (ARGB) | Oui |

> Les libellés français des enums (« Basse », « En cours », etc.) ne sont **pas** stockés dans l'entité : ils sont dérivés à l'affichage via des extensions dans `core/enum_labels.dart`, ce qui garde l'entité propre et sérialisable.

---

## Fonctionnalités obligatoires

### Navigation — sidebar permanente (auto_route)

La navigation utilise `auto_route` avec un layout à onglets persistants. `MainLayoutPage` héberge un `AutoTabsRouter` et une `NavigationRail` toujours visible à gauche. Les routes enfants sont déclarées dans `app_router.dart`, le **tableau de bord** étant la route initiale (`initial: true`). Changer d'onglet ne reconstruit pas toute la page : seul le contenu de droite change.

- **Accueil** : tableau de bord des statistiques (page par défaut).
- **Toutes les tâches** : liste complète, filtres, recherche, vue liste / Kanban.
- **Projets** : liste des projets ; sélectionner un projet affiche ses tâches dans un panneau de détail.
- **Aujourd'hui** : tâches dont l'échéance est aujourd'hui (`todayTasksProvider`).
- **Cette semaine** : tâches de la semaine en cours (`weekTasksProvider`).
- **Paramètres** : préférences (thème).

### CRUD des tâches

- **Créer** — bouton flottant → `showTaskDialog`. Le titre est requis : la sauvegarde est ignorée si le champ est vide (`if (title.isEmpty) return;`).
- **Lire** — liste groupée par statut avec **indicateurs visuels** : barre de couleur de priorité à gauche, badge de priorité, badge de statut, badge du projet associé, et échéance affichée en rouge si en retard.
- **Modifier** — édition via le **panneau de détail** à droite (titre, date, priorité, statut, projet) avec bouton Enregistrer.
- **Supprimer** — confirmation via `AlertDialog` avant suppression.

### Persistance locale

Implémentée avec `shared_preferences` + sérialisation **JSON**. Chaque repository concret lit/écrit une liste sérialisée sous une clé dédiée (`tasks`, `projects`) :

```dart
Future<void> _save(List<Task> tasks) async {
  final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
  await _prefs.setString(_key, jsonString);
}
```

Les préférences de thème sont persistées séparément (clé `darkMode`). Au premier lancement, quelques tâches d'exemple sont injectées (clé `seeded_v2`). Tâches, projets et thème **survivent au redémarrage** de l'application.

### Thème clair/sombre

- Material 3 (`useMaterial3: true`) avec `ColorScheme.fromSeed` (couleur primaire indigo `0xFF4F46E5`).
- Bascule dans **Paramètres** (`SwitchListTile`) et via le raccourci **Ctrl+D**.
- Préférence **persistée** dans `shared_preferences` via `ThemeModeNotifier`.
- Les couleurs de priorité sont gérées par une `ThemeExtension` dédiée (`PriorityColors`), proprement intégrée au thème.

### Configuration de la fenêtre (window_manager)

Dans `main.dart`, la fenêtre est initialisée avec `window_manager` :

```dart
const windowOptions = WindowOptions(
  size: Size(1200, 800),
  minimumSize: Size(800, 600),
  center: true,
  title: 'Task Manager',
);
```

Taille minimale **800×600** et **titre personnalisé** conformes au cahier des charges.

---

## Fonctionnalités bonus

| Bonus | Statut | Détails |
|---|---|---|
| Filtrage & recherche | ✅ Implémenté | Filtres **statut** et **priorité** (menus déroulants) + **recherche textuelle**, combinés dans `filteredTasksProvider`. |
| Drag & Drop | ✅ Implémenté | Vue **Kanban** : glisser une carte d'une colonne à l'autre change son statut (`Draggable` / `DragTarget`). |
| Statistiques | ✅ Implémenté | **Tableau de bord** (page d'accueil) : total, répartition par statut, tâches en retard, répartition par priorité et par projet (`stats_provider.dart`). |
| Build multiplateforme | ✅ Implémenté | Job CI matriciel **macOS / Windows / Linux** (`flutter build` par plateforme). |
| Release / artifacts téléchargeables | ✅ Implémenté | Chaque build est publié comme **artifact** téléchargeable depuis l'onglet Actions (`upload-artifact`). |
| Affichage du projet sur la tâche | ✅ Implémenté | Badge « dossier + nom du projet » sur chaque tâche liée, dans toutes les vues. |
| Vue maître-détail | ✅ Implémenté | Panneau de détail/édition fixe à droite, en remplacement des modales. |

> Pistes non réalisées (facultatives) : sous-tâches, tags colorés, export JSON/CSV, notifications système (`local_notifier`), couverture de tests > 50 %.

---

## Démarche de développement (étape par étape)

Le projet a été construit **du cœur vers l'extérieur**, dans l'esprit de l'architecture hexagonale.

1. **Domaine d'abord.** Définition des entités `Task` et `Project` avec Freezed (immuabilité, `copyWith`, JSON), puis des interfaces `TaskRepository` / `ProjectRepository` décrivant les opérations CRUD sans choisir de technologie de stockage.

2. **Infrastructure.** Première implémentation `InMemory*` (pratique pour démarrer et tester sans I/O), puis les implémentations `SharedPrefs*` qui sérialisent les listes en JSON dans `shared_preferences`.

3. **Application (Riverpod).** Mise en place du `sharedPreferencesProvider` (injecté au démarrage), des providers de repository (`@riverpod`), puis des `AsyncNotifier` `TaskList` / `ProjectList` qui exposent l'état et rappellent le repository avant d'invalider leur état pour recharger.

4. **Présentation — navigation.** Configuration d'`auto_route` avec la `NavigationRail` permanente (`MainLayoutPage` + `AutoTabsRouter`) et les routes enfants.

5. **CRUD & UI de base.** Formulaire de création/édition (validation du titre), liste des tâches, suppression avec `AlertDialog`, page Projets.

6. **Vues dérivées.** Providers « Aujourd'hui » / « Cette semaine » basés sur des extensions de date (`date_extensions.dart`), et lien projet → tâches (`tasksByProjectProvider`).

7. **Formulaire complet.** Ajout progressif des champs : date d'échéance (calendrier), priorité, statut, puis projet associé (dropdown alimenté par `projectListProvider`).

8. **Thème & raccourcis.** Material 3 clair/sombre persistant + raccourcis clavier (`CallbackShortcuts`).

9. **Persistance & seed.** Bascule du stockage mémoire vers `shared_preferences`, données d'exemple au premier lancement.

10. **Tests & CI.** Deux tests `mockito` (repository mocké + provider avec `ProviderContainer`/overrides) et un workflow GitHub Actions.

11. **Bonus — filtres & Kanban.** Filtres (statut/priorité) + recherche, puis vue **Kanban** avec drag & drop.

12. **Refonte UI.** Internationalisation des libellés (FR), tuiles en cartes avec barre de priorité et badges (priorité, statut, projet), en-têtes de section colorés, et passage des modales à un **modèle maître-détail** (panneau fixe à droite) pour les tâches et les projets.

13. **CI multiplateforme.** Séparation en deux jobs : `test` (analyse + tests), puis `build` matriciel macOS/Windows/Linux (avec génération des dossiers de plateforme et publication des **artifacts**). Le focus du raccourci **Ctrl+F** a aussi été branché sur le champ de recherche.

14. **Bonus — tableau de bord.** Provider d'agrégation des statistiques (`stats_provider.dart`) et page d'accueil affichant total, répartition par statut, tâches en retard, et répartitions par priorité et par projet.

Chaque lot a été développé sur une **branche dédiée**, vérifié par `flutter analyze` et `flutter test`, puis fusionné dans `main` via une **Pull Request** une fois la CI au vert.

---

## Installation et lancement

### Prérequis

- Flutter SDK (canal `stable`) — Dart `>=3.4.0`
- Support desktop activé :
  ```bash
  flutter config --enable-macos-desktop   # ou --enable-windows-desktop / --enable-linux-desktop
  ```

### Étapes

```bash
# 1. Récupérer les dépendances
flutter pub get

# 2. Générer le code (Freezed, json_serializable, Riverpod, auto_route)
dart run build_runner build --delete-conflicting-outputs

# 3. Lancer l'application
flutter run -d macos
```

> La génération de code est **nécessaire** : les fichiers `*.freezed.dart`, `*.g.dart` et `app_router.gr.dart` sont produits par `build_runner`.

---

## Tests

Deux tests unitaires avec **mockito**, couvrant les deux cas demandés :

- **Repository mocké** (`test/task_provider_test.dart`) — un `MockTaskRepository` (généré via `@GenerateNiceMocks`) vérifie que `getAll()` renvoie la liste attendue.
- **Provider avec overrides** (`test/task_provider_test.dart`) — un `ProviderContainer` override le `taskRepositoryProvider` par le mock, puis on vérifie qu'`addTask` appelle bien le repository.

Un test de widget (`test/task_tile_test.dart`) vérifie en plus l'affichage d'une `TaskTile`.

```bash
flutter test
```

---

## Intégration continue (CI)

Workflow **GitHub Actions** (`.github/workflows/ci.yml`) déclenché sur `push` et `pull_request` vers `main`. Il est organisé en **deux jobs** :

### Job `test` (qualité)

1. Checkout du code
2. Installation de Flutter (canal `stable`, avec cache)
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `flutter analyze`
6. `flutter test`

### Job `build` (multiplateforme)

Ne démarre que si le job `test` est vert (`needs: test`). Matrice **macOS / Windows / Linux** (`fail-fast: false`) :

1. Checkout du code
2. Dépendances système GTK (Linux uniquement)
3. Installation de Flutter
4. Activation du support desktop de la plateforme
5. Génération des dossiers de plateforme (`flutter create . --platforms=...`)
6. `flutter pub get` + génération de code
7. `flutter build <plateforme> --release`
8. Publication du binaire en **artifact** téléchargeable (`upload-artifact`)

Toute PR doit passer ces vérifications (CI verte) avant d'être fusionnée dans `main`.

---

## Raccourcis clavier

Implémentés via `CallbackShortcuts` dans `MainLayoutPage`.

| Raccourci | Action |
|---|---|
| `Ctrl + N` | Nouvelle tâche (ouvre le formulaire) |
| `Ctrl + D` | Basculer le thème clair/sombre |
| `Ctrl + F` | Aller à « Toutes les tâches » et placer le curseur dans le champ de recherche |

---

## Checklist du rendu

- [x] L'application se lance sans erreur
- [x] Architecture hexagonale (4 couches distinctes)
- [x] Entités avec Freezed
- [x] CRUD des tâches complet
- [x] Navigation auto_route avec sidebar permanente
- [x] Persistance entre redémarrages (shared_preferences + JSON)
- [x] Thème clair/sombre fonctionnel et persisté
- [x] Au moins 3 raccourcis clavier
- [x] Taille minimale de fenêtre configurée (800×600)
- [x] Au moins 2 tests unitaires
- [x] Dépôt GitHub avec workflow CI fonctionnel
- [x] Code propre et organisé
- [x] **Bonus** : filtres + recherche, drag & drop (Kanban), tableau de bord de statistiques, build multiplateforme + artifacts téléchargeables

---

_Rendu à envoyer par mail à `loic.kervran@ynov.com` avec le lien du dépôt GitHub._