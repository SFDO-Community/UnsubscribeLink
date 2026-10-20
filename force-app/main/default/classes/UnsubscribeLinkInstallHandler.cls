global with sharing class UnsubscribeLinkInstallHandler implements InstallHandler {
  global void onInstall(InstallContext context) {
    UnsubscribeLinkInstallService.install(!context.isUpgrade(), context.installerId());
  }
}
