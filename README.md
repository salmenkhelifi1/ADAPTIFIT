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


I've created the assets/images directory. Now, place your app_icon.png (1024x1024px minimum) and transparent splash_logo.png into /Users/salmenkhelifi/ADAPTIFIT/adaptifit/assets/images. Then, in your terminal, navigate to /Users/salmenkhelifi/ADAPTIFIT/adaptifit/ and run flutter pub get, flutter pub run flutter_native_splash:create, and flutter pub run flutter_launcher_icons. This will update your app's branding. I've completed my assistance with the logo change.



## Typography Guidelines

•⁠  ⁠Do NOT use Tailwind font size classes (e.g. text-2xl), font weight classes (e.g. font-bold), or line-height classes (e.g. leading-none) unless specifically requested
•⁠  ⁠Use the default typography hierarchy defined in globals.css
•⁠  ⁠Font sizes: H1 (28px), H2 (20px), Body (16px), Caption (14px)
•⁠  ⁠Font weights: Medium (500) for headings and buttons, Normal (400) for body text

## Color System

•⁠  ⁠Primary Green: #1EB955 (CTAs and primary actions)
•⁠  ⁠Secondary Blue: #3A7DFF (progress indicators)
•⁠  ⁠Dark Text: #1A1A1A (primary text)
•⁠  ⁠Neutral Gray: #DFF1F0 (background color)
•⁠  ⁠White: #FFFFFF (cards and containers)
•⁠  ⁠Timestamp Gray: #999999 (secondary/meta text)