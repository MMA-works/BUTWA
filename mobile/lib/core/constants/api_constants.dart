class ApiConstants {
  // 24/7 Serverless Google Cloud Web App
  static String baseUrl = 'https://script.google.com/macros/s/AKfycbzoLRzxEdGwLHyxKik_TWyBgnrmMUe7RO3hkn7VIKVh1QApp0x69UIasWYtbJABLnz1/exec';
  static const String defaultBaseUrl = 'https://script.google.com/macros/s/AKfycbzoLRzxEdGwLHyxKik_TWyBgnrmMUe7RO3hkn7VIKVh1QApp0x69UIasWYtbJABLnz1/exec';
  
  // Auth Endpoints
  static const String verifyEmail = '/auth/verify-email';
  static const String checkCnic = '/auth/check-cnic';
  static const String checkUsername = '/auth/check-username';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String setPin = '/auth/pin';
  static const String currentUser = '/auth/me';
  static const String sendEmailCode = '/auth/email/send-code';
  static const String verifyEmailCode = '/auth/email/verify-code';
  static const String forgotPassword = '/auth/password/forgot';
  static const String resetPassword = '/auth/password/reset';
  
  // Wallet Endpoints
  static const String myWallet = '/wallets/me';
  static const String lookupRecipient = '/wallets/lookup';
  static const String topUp = '/wallets/topup';
  static const String transfer = '/wallets/transfer';
  
  // Transaction Endpoints
  static const String transactions = '/transactions';

  // Virtual Cards Endpoints
  static const String generateCard = '/cards/generate';
  static const String myCards = '/cards/my-cards';
  static String freezeCard(String id) => '/cards/$id/freeze';
  static String toggleOnlineCard(String id) => '/cards/$id/toggle-online';

  // Utility Bills Endpoints
  static const String billCompanies = '/bills/companies';
  static const String billInquiry = '/bills/inquiry';
  static const String payBill = '/bills/pay';

  // Savings Pots / Vaults Endpoints
  static const String vaults = '/vaults';
  static String vaultDeposit(String id) => '/vaults/$id/deposit';
  static String vaultWithdraw(String id) => '/vaults/$id/withdraw';
  static String vaultToggleLock(String id) => '/vaults/$id/toggle-lock';

  // Split Bills Endpoints
  static const String splits = '/splits';
  static const String myCreatedSplits = '/splits/my-splits';
  static const String pendingSplits = '/splits/pending';
  static const String splitsPending = '/splits/pending';
  static String settleSplit(String id) => '/splits/$id/settle';
  static String splitSettle(String id) => '/splits/$id/settle';
  static String splitCancel(String id) => '/splits/$id';

  // Security & Settings Endpoints
  static const String securitySettings = '/security/settings';
  static const String securitySessions = '/security/sessions';
  static String revokeSession(String id) => '/security/sessions/$id';
  static const String revokeOtherSessions = '/security/sessions/revoke-others';
  static const String changePin = '/security/pin/change';
  static const String resetPin = '/security/pin/reset';
  static const String verifyPin = '/security/pin/verify';
  static const String securityAuditLogs = '/security/audit-logs';

  // QR Payment Endpoints
  static const String qrMyCode = '/qr/my-code';
  static const String qrGenerateDynamic = '/qr/generate-dynamic';
  static const String qrParse = '/qr/parse';
  static const String qrPay = '/qr/pay';

  // Recurring & Scheduled Payments Endpoints
  static const String recurring = '/recurring';
  static String recurringToggle(String id) => '/recurring/$id/toggle';
  static String recurringDelete(String id) => '/recurring/$id';
  static String recurringExecuteNow(String id) => '/recurring/$id/execute-now';

  // Smart Analytics & Budgeting Endpoints
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsBudgets = '/analytics/budgets';
  static String analyticsBudgetDelete(String id) => '/analytics/budgets/$id';

  // Merchant POS & Invoicing Endpoints
  static const String merchantProfile = '/merchant/profile';
  static const String merchantDashboard = '/merchant/dashboard';
  static const String merchantInvoices = '/merchant/invoices';
  static const String merchantPosOrder = '/merchant/pos-order';
  static const String merchantPayInvoice = '/merchant/invoices/pay';
  static String merchantInvoiceByNumber(String num) => '/merchant/invoices/$num';
}
