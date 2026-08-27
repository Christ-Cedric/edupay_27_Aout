class ApiRoutes {
  const ApiRoutes._();

  static const profile = '/parents/me';
  static const family = '/parents/me/family';
  static const children = '/parents/me/children';
  static String child(String id) => '$children/$id';
  static String childKit(String id) => '${child(id)}/kit';
  static const catalogKits = '/catalog/kits';
  static const contributions = '/parents/me/contributions';
  static const subscriptionConfirmation = '/parents/me/subscription/confirm';
  // Livraison
  static const delivery = '/parents/me/delivery';
  static const deliveryLocation = '/parents/me/delivery/location';
  static const deliveryConfirmReceipt = '/parents/me/delivery/confirm-receipt';
  static const deliveryIssues = '/parents/me/delivery/issues';
  // Remboursements
  static const refunds = '/parents/me/refunds';
  // Notifications (route de listing scopée au rôle ; marquage lu commun aux
  // 3 rôles, monté à la racine `/notifications`, pas sous `/parents/me`).
  static const notifications = '/parents/me/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationDeviceToken = '/notifications/device-token';
  static const authRequestOtp = '/auth/otp/request';
  static const authVerifyOtp = '/auth/otp/verify';
  // Inscription : finalise le compte (profil + mot de passe) après l'OTP.
  static const authRegister = '/auth/register';
  // Reconnexion d'un compte existant avec numéro + mot de passe (sans OTP).
  static const authLogin = '/auth/login';
}
