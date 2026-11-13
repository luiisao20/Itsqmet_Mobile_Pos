# itsqmet_mobile_pos

### Reemplazar un placeholder

- Cada feature tiene su test de placeholder en `test/presentation/screens/<feature>/<feature>_placeholder_test.dart` (admin: `test/presentation/screens/admin/tabs/admin_catalogo_placeholder_test.dart` y `admin_personas_placeholder_test.dart`). Ese archivo pertenece a la rama de la feature: bórralo al reemplazar el placeholder y escribe los tests reales de tu pantalla.
- Los tests compartidos (`app_test.dart`, `app_router_test.dart`, `admin_screen_test.dart`) no construyen pantallas reales: usan `screenBuilder` de `createAppRouter` y `tabBuilder`/`metrics` de `AdminScreen` con stubs, así que no hace falta registrar dependencias de features en ellos.
