Every module must expose:

lib/
├── module.dart
├── public_api.dart

Consumers must import only public_api.dart.

Forbidden:

import internal sources from another module.

Example:

Allowed:
import package:forum_module/public_api.dart

Forbidden:
import package:forum_module/src/data/forum_repository.dart
