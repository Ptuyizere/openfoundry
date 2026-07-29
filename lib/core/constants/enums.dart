
enum UserRole { entrepreneur, backer }

enum FundingType { grant, loan, equity }

enum PaymentMethod { mpesa, momo }

enum PitchStatus { open, closed }

extension FundingTypeX on FundingType {
  String get label {
    switch (this) {
      case FundingType.grant:
        return 'Grant';
      case FundingType.loan:
        return 'Loan';
      case FundingType.equity:
        return 'Equity Share';
    }
  }
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.momo:
        return 'Momo';
    }
  }
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.entrepreneur:
        return 'Entrepreneur';
      case UserRole.backer:
        return 'Backer';
    }
  }
}




