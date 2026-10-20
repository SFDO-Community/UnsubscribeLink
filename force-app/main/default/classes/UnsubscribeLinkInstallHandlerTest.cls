@isTest
private class UnsubscribeLinkInstallHandlerTest {
  private static Integer userSequence = 0;

  @isTest
  static void freshInstallCreatesOptOutAccessAndAssignsIt() {
    User installer = createUser('Standard User', true);
    User administrator = [
      SELECT Id
      FROM User
      WHERE IsActive = TRUE AND Profile.Name = 'System Administrator'
      LIMIT 1
    ];

    System.runAs(runningUser()) {
      Test.startTest();
      install(false, installer.Id);
      install(false, installer.Id);
      Test.stopTest();
    }

    PermissionSet localPermissionSet = localPermissionSet();
    System.assertEquals(
      UnsubscribeLinkInstallService.LOCAL_DESCRIPTION,
      localPermissionSet.Description,
      'local permission set should describe the Email Opt Out grant'
    );
    assertOptOutFields(localPermissionSet.Id);
    System.assertEquals(
      1,
      assignmentCount(installer.Id, localPermissionSet.Id),
      'installer should receive the local permission set once'
    );
    System.assertEquals(
      1,
      assignmentCount(administrator.Id, localPermissionSet.Id),
      'System Administrator should receive the local permission set once'
    );

    Id packagedPermissionSetId = UnsubscribeLinkInstallService.findPackagedPermissionSetId();
    if (packagedPermissionSetId != null) {
      System.assertEquals(
        1,
        assignmentCount(installer.Id, packagedPermissionSetId),
        'installer should receive the packaged permission set once'
      );
    }
  }

  @isTest
  static void upgradeCreatesMissingSetWithoutAssigning() {
    User installer = createUser('Standard User', true);

    System.runAs(runningUser()) {
      Test.startTest();
      install(true, installer.Id);
      install(true, installer.Id);
      Test.stopTest();
    }

    PermissionSet localPermissionSet = localPermissionSet();
    assertOptOutFields(localPermissionSet.Id);
    System.assertEquals(
      0,
      assignmentCount(installer.Id, localPermissionSet.Id),
      'upgrade should leave assignment to the admin'
    );
  }

  @isTest
  static void freshInstallRepairsFieldAccessOnThePackageOwnedSet() {
    System.runAs(runningUser()) {
      insert new PermissionSet(
        Name = UnsubscribeLinkInstallService.LOCAL_PERMISSION_SET_NAME,
        Label = UnsubscribeLinkInstallService.LOCAL_PERMISSION_SET_LABEL,
        Description = UnsubscribeLinkInstallService.LOCAL_DESCRIPTION
      );
      Test.startTest();
      install(true, null);
      Test.stopTest();
    }

    assertOptOutFields(localPermissionSet().Id);
  }

  @isTest
  static void freshInstallLeavesASubscriberPermissionSetAlone() {
    User installer = createUser('Standard User', true);

    System.runAs(runningUser()) {
      insert new PermissionSet(
        Name = UnsubscribeLinkInstallService.LOCAL_PERMISSION_SET_NAME,
        Label = 'Existing Opt Out',
        Description = 'Subscriber owned'
      );
      Test.startTest();
      install(false, installer.Id);
      Test.stopTest();
    }

    PermissionSet subscriberPermissionSet = localPermissionSet();
    System.assertEquals(
      'Subscriber owned',
      subscriberPermissionSet.Description,
      'an existing subscriber permission set should keep its description'
    );
    System.assertEquals(
      0,
      [
        SELECT COUNT()
        FROM FieldPermissions
        WHERE ParentId = :subscriberPermissionSet.Id AND Field IN :optOutFields()
      ],
      'an existing subscriber permission set should not gain Email Opt Out'
    );
    System.assertEquals(
      0,
      assignmentCount(installer.Id, subscriberPermissionSet.Id),
      'an existing subscriber permission set should not be assigned'
    );
  }

  @isTest
  static void freshInstallSkipsAnInactiveInstaller() {
    User installer = createUser('Standard User', false);

    System.runAs(runningUser()) {
      Test.startTest();
      install(false, installer.Id);
      Test.stopTest();
    }

    System.assertEquals(
      0,
      assignmentCount(installer.Id, localPermissionSet().Id),
      'an inactive installer should not receive the local permission set'
    );
  }

  private static void install(Boolean isUpgrade, Id installerId) {
    new UnsubscribeLinkInstallHandler()
      .onInstall(new InstallContextStub(isUpgrade, installerId));
  }

  private static User createUser(String profileName, Boolean isActive) {
    userSequence++;
    Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
    String token = String.valueOf(DateTime.now().getTime()) + userSequence;
    User created = new User(
      Alias = ('ul' + token).right(8),
      Email = 'ul' + token + '@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Install',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profile.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = 'ul' + token + '@example.com'
    );
    insert created;
    if (!isActive) {
      created.IsActive = false;
      update created;
    }
    return created;
  }

  private static User runningUser() {
    return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
  }

  private static PermissionSet localPermissionSet() {
    return [
      SELECT Id, Description
      FROM PermissionSet
      WHERE
        Name = :UnsubscribeLinkInstallService.LOCAL_PERMISSION_SET_NAME
        AND NamespacePrefix = NULL
    ];
  }

  private static void assertOptOutFields(Id permissionSetId) {
    Map<String, FieldPermissions> fieldsByName = new Map<String, FieldPermissions>();
    for (FieldPermissions fieldPermission : [
      SELECT Field, PermissionsRead, PermissionsEdit
      FROM FieldPermissions
      WHERE ParentId = :permissionSetId AND Field IN :optOutFields()
    ]) {
      fieldsByName.put(fieldPermission.Field, fieldPermission);
    }
    for (String fieldName : optOutFields()) {
      FieldPermissions fieldPermission = fieldsByName.get(fieldName);
      System.assertNotEquals(null, fieldPermission, fieldName + ' should be granted');
      System.assertEquals(true, fieldPermission.PermissionsRead, fieldName + ' should be readable');
      System.assertEquals(true, fieldPermission.PermissionsEdit, fieldName + ' should be editable');
    }
  }

  private static Integer assignmentCount(Id userId, Id permissionSetId) {
    return [
      SELECT COUNT()
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId AND PermissionSetId = :permissionSetId
    ];
  }

  private static List<String> optOutFields() {
    return new List<String>{ 'Contact.HasOptedOutOfEmail', 'Lead.HasOptedOutOfEmail' };
  }

  private class InstallContextStub implements InstallContext {
    private Boolean upgrade;
    private Id installer;

    InstallContextStub(Boolean upgrade, Id installer) {
      this.upgrade = upgrade;
      this.installer = installer;
    }

    public Id organizationId() {
      return UserInfo.getOrganizationId();
    }

    public Id installerId() {
      return installer;
    }

    public Boolean isUpgrade() {
      return upgrade;
    }

    public Boolean isPush() {
      return false;
    }

    public Version previousVersion() {
      return upgrade ? new Version(0, 1) : null;
    }
  }
}
