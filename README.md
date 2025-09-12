# ADAPTIFIT
Le projet vise à développer une application mobile de fitness et de nutrition de nouvelle génération pour iOS et Android. L'objectif est de fournir aux utilisateurs un plan d'entraînement et de nutrition simple, hautement personnalisé et généré par une intelligence artificielle (IA).

lib/
└── src/
    ├── components/            # Widgets réutilisables et génériques
    │   ├── buttons/
    │   ├── inputs/
    │   └── custom_card.dart
    │
    ├── constants/             # Constantes globales (couleurs, styles, clés, etc.)
    │   ├── app_colors.dart
    │   ├── app_strings.dart
    │   └── app_styles.dart
    │
    ├── context/               # Providers / Riverpod / Bloc / GetIt contextuels
    │   ├── app_context.dart
    │   └── theme_context.dart
    │
    ├── core/                  # Logique bas niveau (models, exceptions, config, API)
    │   ├── models/
    │   ├── exceptions/
    │   ├── config/
    │   └── api/
    │
    ├── hooks/                 # Hooks personnalisés (si tu utilises flutter_hooks par ex.)
    │   └── use_auth.dart
    │
    ├── i18n/                  # Internationalisation
    │   ├── en.json
    │   ├── fr.json
    │   └── i18n.dart
    │
    ├── navigation/            # Routes & navigation
    │   ├── app_router.dart
    │   └── routes.dart
    │
    ├── screens/               # Pages de l’application
    │   ├── home/
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   ├── login/
    │   │   └── login_screen.dart
    │   └── splash/
    │       └── splash_screen.dart
    │
    ├── services/              # Services (API, Firebase, LocalStorage…)
    │   ├── api_service.dart
    │   ├── auth_service.dart
    │   └── storage_service.dart
    │
    └── utils/                 # Fonctions utilitaires
        ├── validators.dart
        ├── formatters.dart
        └── logger.dart
