import 'package:agenda_pet/core/state/pets_store.dart';
import 'package:agenda_pet/core/state/reminders_store.dart';
import 'package:agenda_pet/features/pets/data/pet_dto.dart';
import 'package:agenda_pet/features/reminders/data/reminder_dto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comprueba que "Guardar" realmente agrega datos y avisa a las pantallas.
/// Con USE_BACKEND=false corre contra los repositorios en memoria.
void main() {
  setUp(() {
    PetsStore.instance.reset();
    RemindersStore.instance.reset();
  });

  test('crear una mascota la agrega al store y notifica a las pantallas', () async {
    final store = PetsStore.instance;
    await store.load(force: true);
    final antes = store.pets.length;

    var avisos = 0;
    void escucha() => avisos++;
    store.addListener(escucha);

    final creada = await store.add(
      const PetDto(id: '', name: 'Pelusa', species: 'Gato', breed: 'Siamés'),
    );

    store.removeListener(escucha);

    expect(creada.id, isNotEmpty, reason: 'el repositorio asigna un id');
    expect(store.pets.length, antes + 1);
    expect(store.pets.last.name, 'Pelusa');
    expect(store.selected?.name, 'Pelusa', reason: 'queda seleccionada');
    expect(avisos, greaterThan(0), reason: 'la UI se entera del cambio');
  });

  test('la mascota creada sigue ahí al recargar la lista', () async {
    final store = PetsStore.instance;
    await store.load(force: true);
    await store.add(const PetDto(id: '', name: 'Rocco', species: 'Perro'));

    store.reset();
    await store.load(force: true);

    expect(store.pets.map((p) => p.name), contains('Rocco'));
  });

  test('crear un recordatorio lo deja en los próximos de la mascota', () async {
    final pets = PetsStore.instance;
    await pets.load(force: true);
    final mascota = pets.pets.first;

    final store = RemindersStore.instance;
    await store.loadFor(mascota.id, force: true);
    final pendientesAntes = store.pendingCount;

    await store.add(
      mascota.id,
      ReminderDto(
        id: '',
        title: 'Control veterinario',
        type: 'Agenda',
        dueAt: DateTime.now().add(const Duration(days: 3)),
      ),
    );

    expect(store.pendingCount, pendientesAntes + 1);
    expect(
      store.upcoming.map((r) => r.title),
      contains('Control veterinario'),
    );
  });

  test('marcar un recordatorio como hecho lo saca de los próximos', () async {
    final pets = PetsStore.instance;
    await pets.load(force: true);
    final mascota = pets.pets.first;

    final store = RemindersStore.instance;
    await store.loadFor(mascota.id, force: true);
    final objetivo = store.upcoming.first;

    await store.toggleDone(mascota.id, objetivo);

    expect(store.upcoming.map((r) => r.id), isNot(contains(objetivo.id)));
  });
}
