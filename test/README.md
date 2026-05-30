# BeValue — suíte completa de testes

Este pacote contém uma suíte ampliada de testes para o projeto Flutter BeValue.

## Como usar

Copie a pasta `test/` para a raiz do projeto e rode:

```bash
flutter test
```

## Dependências de teste recomendadas

A maioria dos testes usa apenas `flutter_test`. Os testes de serviços/modelos Firestore usam fakes/mocks. Adicione ao `pubspec.yaml` se ainda não existir:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: any
  firebase_auth_mocks: any
```

Se sua versão do Flutter/Firebase exigir versões diferentes desses pacotes, ajuste para versões compatíveis com o seu `pubspec.lock`.

## Cobertura incluída

- Configurações e constantes: app, legal, collections, fields e rotas.
- Persistência local: `SharedPrefsLocalStorage` e `OnboardingLocalStore`.
- Validadores: CPF, e-mail, senha, confirmação, conselho, nome, horário, data, decimal positivo, obrigatórios, termos e código.
- Domínio: `UserRole`, `AppUserProfile`, onboarding e entidades/enums do paciente.
- Models Firestore: `MedicationModel`, `AlarmModel`, `AdherenceEventModel`.
- Services Firestore: medicamentos, alarmes, eventos de adesão, aceite legal e agendador de alarmes.
- Widgets reutilizáveis: botões, campos, feedback, layout, navegação, cards, dialogs, profile e alguns widgets de feature.

## Observação

Os testes foram escritos para rodar sem emulador Firebase real, usando `fake_cloud_firestore` e `firebase_auth_mocks`.
