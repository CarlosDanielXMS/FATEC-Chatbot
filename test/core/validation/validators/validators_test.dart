import 'package:chatbot/core/validation/validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CpfValidator', () {
    test('normaliza removendo caracteres não numéricos', () {
      expect(CpfValidator.normalize('123.456.789-09'), '12345678909');
    });

    test('aceita CPF válido e rejeita inválidos', () {
      expect(CpfValidator.isValid('529.982.247-25'), isTrue);
      expect(CpfValidator.isValid('52998224725'), isTrue);
      expect(CpfValidator.isValid('111.111.111-11'), isFalse);
      expect(CpfValidator.isValid('123'), isFalse);
      expect(CpfValidator.validate('').errorMessage, 'Informe o CPF.');
    });
  });

  group('EmailValidator', () {
    test('aceita formato válido e rejeita entradas inválidas', () {
      expect(EmailValidator.isValid('user@example.com'), isTrue);
      expect(EmailValidator.isValid(' user@example.com '), isTrue);
      expect(EmailValidator.isValid('user@example'), isFalse);
      expect(EmailValidator.isValid('user@'), isFalse);
      expect(EmailValidator.validate('').errorMessage, 'Informe o e-mail.');
    });
  });

  group('FullNameValidator', () {
    test('normaliza espaços e valida nome completo', () {
      expect(FullNameValidator.normalize('  Maria   Silva  '), 'Maria Silva');
      expect(FullNameValidator.isValid('Maria Silva'), isTrue);
      expect(FullNameValidator.isValid('Maria'), isFalse);
      expect(FullNameValidator.isValid('Maria 1'), isFalse);
      expect(FullNameValidator.isValid('M Silva'), isFalse);
    });
  });

  group('CouncilValidator', () {
    test('normaliza e valida conselho profissional', () {
      expect(CouncilValidator.normalize('  CRM   123  '), 'CRM 123');
      expect(CouncilValidator.isValid('CRM 12345'), isTrue);
      expect(CouncilValidator.isValid('CRM'), isFalse);
      expect(CouncilValidator.isValid('CRM ABCD'), isFalse);
      expect(CouncilValidator.isValid('CRM@123'), isFalse);
    });
  });

  group('LoginIdentifierValidator', () {
    test('aceita e-mail ou CPF válidos', () {
      expect(LoginIdentifierValidator.isValid('user@example.com'), isTrue);
      expect(LoginIdentifierValidator.isValid('529.982.247-25'), isTrue);
      expect(LoginIdentifierValidator.isValid('abc'), isFalse);
      expect(LoginIdentifierValidator.validate('').errorMessage, 'Informe o e-mail ou CPF.');
    });
  });

  group('PasswordValidator', () {
    test('valida todos os requisitos da senha', () {
      final valid = PasswordValidator.validate('Senha@123');

      expect(valid.isValid, isTrue);
      expect(valid.hasMinLength, isTrue);
      expect(valid.hasUppercase, isTrue);
      expect(valid.hasLowercase, isTrue);
      expect(valid.hasNumber, isTrue);
      expect(valid.hasSpecialChar, isTrue);
    });

    test('retorna mensagens por requisito faltante', () {
      expect(PasswordValidator.validate('').errorMessage, 'Informe a senha.');
      expect(PasswordValidator.validate('A1@a').errorMessage, 'A senha deve ter no mínimo 8 caracteres.');
      expect(PasswordValidator.validate('senha@123').errorMessage, 'A senha deve ter pelo menos 1 letra maiúscula.');
      expect(PasswordValidator.validate('SENHA@123').errorMessage, 'A senha deve ter pelo menos 1 letra minúscula.');
      expect(PasswordValidator.validate('Senha@@@').errorMessage, 'A senha deve ter pelo menos 1 número.');
      expect(PasswordValidator.validate('Senha1234').errorMessage, 'A senha deve ter pelo menos 1 caractere especial.');
    });
  });

  group('PasswordConfirmationValidator', () {
    test('valida igualdade entre senha e confirmação', () {
      expect(
        PasswordConfirmationValidator.isValid(password: 'Senha@123', confirmation: 'Senha@123'),
        isTrue,
      );
      expect(
        PasswordConfirmationValidator.validate(password: '', confirmation: '').errorMessage,
        'Informe a senha.',
      );
      expect(
        PasswordConfirmationValidator.validate(password: 'Senha@123', confirmation: '').errorMessage,
        'Confirme a senha.',
      );
      expect(
        PasswordConfirmationValidator.validate(password: 'Senha@123', confirmation: 'Outra@123').errorMessage,
        'As senhas não coincidem.',
      );
    });
  });

  group('DateRangeValidator', () {
    test('aceita datas iguais ou final depois da inicial', () {
      final start = DateTime(2026, 3, 7, 15);

      expect(DateRangeValidator.isValid(startDate: start, endDate: DateTime(2026, 3, 7, 8)), isTrue);
      expect(DateRangeValidator.isValid(startDate: start, endDate: DateTime(2026, 3, 8)), isTrue);
      expect(DateRangeValidator.isValid(startDate: start, endDate: DateTime(2026, 3, 6)), isFalse);
    });

    test('retorna mensagem para datas ausentes', () {
      expect(
        DateRangeValidator.validate(startDate: null, endDate: DateTime(2026)).errorMessage,
        'Informe a data inicial.',
      );
      expect(
        DateRangeValidator.validate(startDate: DateTime(2026), endDate: null).errorMessage,
        'Informe a data final.',
      );
    });
  });

  group('PositiveDecimalValidator', () {
    test('aceita decimal com ponto ou vírgula e rejeita zero/negativo/inválido', () {
      expect(PositiveDecimalValidator.isValid('1'), isTrue);
      expect(PositiveDecimalValidator.isValid('1,5'), isTrue);
      expect(PositiveDecimalValidator.isValid('2.75'), isTrue);
      expect(PositiveDecimalValidator.isValid('0'), isFalse);
      expect(PositiveDecimalValidator.isValid('-1'), isFalse);
      expect(PositiveDecimalValidator.isValid('abc'), isFalse);
      expect(PositiveDecimalValidator.validate('').errorMessage, 'Informe um valor.');
    });
  });

  group('RequiredListValidator e RequiredTextValidator', () {
    test('validam presença de valores', () {
      expect(RequiredListValidator.isValid([1]), isTrue);
      expect(RequiredListValidator.isValid(<int>[]), isFalse);
      expect(RequiredTextValidator.isValid(' texto '), isTrue);
      expect(RequiredTextValidator.isValid('   '), isFalse);
    });
  });

  group('TermsAcceptanceValidator', () {
    test('exige aceite dos termos', () {
      expect(TermsAcceptanceValidator.isValid(true), isTrue);
      expect(TermsAcceptanceValidator.isValid(false), isFalse);
      expect(
        TermsAcceptanceValidator.validate(false).errorMessage,
        'Você precisa aceitar os Termos de Uso e Privacidade.',
      );
    });
  });

  group('TimeTextValidator', () {
    test('aceita HH:mm e rejeita horários inválidos', () {
      expect(TimeTextValidator.isValid('00:00'), isTrue);
      expect(TimeTextValidator.isValid('23:59'), isTrue);
      expect(TimeTextValidator.isValid('24:00'), isFalse);
      expect(TimeTextValidator.isValid('9:00'), isFalse);
      expect(TimeTextValidator.isValid('12:60'), isFalse);
      expect(TimeTextValidator.validate('').errorMessage, 'Informe o horário.');
    });
  });

  group('VerificationCodeValidator', () {
    test('exige cinco dígitos numéricos', () {
      expect(VerificationCodeValidator.codeLength, 5);
      expect(VerificationCodeValidator.isValid('12345'), isTrue);
      expect(VerificationCodeValidator.isValid('1234'), isFalse);
      expect(VerificationCodeValidator.isValid('12a45'), isFalse);
      expect(VerificationCodeValidator.validate('').errorMessage, 'Informe o código de verificação.');
    });
  });
}
