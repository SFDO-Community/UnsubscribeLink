// User-mode DML is omitted on purpose. The package install user has no profile,
// so WITH USER_MODE and "as user" would fail while creating this access.
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class UnsubscribeLinkInstallService {
  public static final String PACKAGED_PERMISSION_SET_NAME = 'Unsubscribe_Link';
  public static final String LOCAL_PERMISSION_SET_NAME = 'Unsubscribe_Link_Email_Opt_Out';
  public static final String LOCAL_PERMISSION_SET_LABEL = 'Unsubscribe Link Email Opt Out';
  public static final String LOCAL_DESCRIPTION =
    'Created by Unsubscribe Link. Grants read and edit on the Contact and Lead Email Opt Out fields. Assign this set together with the Unsubscribe Link permission set.';
  private static final String NAMESPACE = 'UnsubscribeLnk';
  private static final String SALESFORCE_USER_LICENSE = 'Salesforce';
  private static final List<String> OPT_OUT_FIELDS = new List<String>{
    'Contact.HasOptedOutOfEmail',
    'Lead.HasOptedOutOfEmail'
  };

  public static void install(Boolean isFreshInstall, Id installerId) {
    Id packagedPermissionSetId = findPackagedPermissionSetId();
    Id localPermissionSetId = ensureLocalPermissionSet();
    // An upgrade must not put the set back on a user an admin removed.
    if (isFreshInstall) {
      assignPermissionSets(packagedPermissionSetId, localPermissionSetId, installerId);
    }
  }

  @TestVisible
  private static Id findPackagedPermissionSetId() {
    Id namespacedId;
    Id unpackagedId;
    for (PermissionSet permissionSet : [
      SELECT Id, NamespacePrefix
      FROM PermissionSet
      WHERE
        IsOwnedByProfile = FALSE
        AND Name = :PACKAGED_PERMISSION_SET_NAME
        AND (NamespacePrefix = :NAMESPACE
        OR NamespacePrefix = NULL)
    ]) {
      if (permissionSet.NamespacePrefix == NAMESPACE) {
        namespacedId = permissionSet.Id;
      } else {
        unpackagedId = permissionSet.Id;
      }
    }
    return namespacedId == null ? unpackagedId : namespacedId;
  }

  private static Id ensureLocalPermissionSet() {
    List<PermissionSet> existing = [
      SELECT Id, Description
      FROM PermissionSet
      WHERE
        IsOwnedByProfile = FALSE
        AND Name = :LOCAL_PERMISSION_SET_NAME
        AND NamespacePrefix = NULL
    ];
    if (!existing.isEmpty()) {
      // Same API name owned by the subscriber. Leave that permission set alone.
      if (existing[0].Description != LOCAL_DESCRIPTION) {
        return null;
      }
      ensureFieldPermissions(existing[0].Id);
      return existing[0].Id;
    }

    PermissionSet localPermissionSet = new PermissionSet(
      Name = LOCAL_PERMISSION_SET_NAME,
      Label = LOCAL_PERMISSION_SET_LABEL,
      Description = LOCAL_DESCRIPTION
    );
    insert localPermissionSet;
    ensureFieldPermissions(localPermissionSet.Id);
    return localPermissionSet.Id;
  }

  private static void ensureFieldPermissions(Id permissionSetId) {
    Set<String> presentFields = new Set<String>();
    for (FieldPermissions fieldPermission : [
      SELECT Field
      FROM FieldPermissions
      WHERE ParentId = :permissionSetId AND Field IN :OPT_OUT_FIELDS
    ]) {
      presentFields.add(fieldPermission.Field);
    }

    List<FieldPermissions> missingFields = new List<FieldPermissions>();
    for (String fieldName : OPT_OUT_FIELDS) {
      if (presentFields.contains(fieldName)) {
        continue;
      }
      missingFields.add(
        new FieldPermissions(
          ParentId = permissionSetId,
          SobjectType = fieldName.substringBefore('.'),
          Field = fieldName,
          PermissionsRead = true,
          PermissionsEdit = true
        )
      );
    }
    if (!missingFields.isEmpty()) {
      insert missingFields;
    }
  }

  private static void assignPermissionSets(
    Id packagedPermissionSetId,
    Id localPermissionSetId,
    Id installerId
  ) {
    Set<Id> candidateIds = new Set<Id>();
    for (User adminUser : [
      SELECT Id
      FROM User
      WHERE IsActive = TRUE AND Profile.Name = 'System Administrator'
    ]) {
      candidateIds.add(adminUser.Id);
    }
    if (installerId != null) {
      candidateIds.add(installerId);
    }
    if (candidateIds.isEmpty()) {
      return;
    }

    Map<Id, User> usersById = new Map<Id, User>(
      [
        SELECT Id, Profile.UserLicense.Name
        FROM User
        WHERE Id IN :candidateIds AND IsActive = TRUE
      ]
    );
    if (usersById.isEmpty()) {
      return;
    }

    Set<Id> permissionSetIds = new Set<Id>();
    if (localPermissionSetId != null) {
      permissionSetIds.add(localPermissionSetId);
    }
    if (packagedPermissionSetId != null) {
      permissionSetIds.add(packagedPermissionSetId);
    }
    if (permissionSetIds.isEmpty()) {
      return;
    }

    Set<String> existingKeys = new Set<String>();
    for (PermissionSetAssignment existingAssignment : [
      SELECT AssigneeId, PermissionSetId
      FROM PermissionSetAssignment
      WHERE AssigneeId IN :usersById.keySet() AND PermissionSetId IN :permissionSetIds
    ]) {
      existingKeys.add(
        assignmentKey(existingAssignment.AssigneeId, existingAssignment.PermissionSetId)
      );
    }

    List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
    for (User candidate : usersById.values()) {
      if (localPermissionSetId != null) {
        addAssignment(assignments, existingKeys, candidate.Id, localPermissionSetId);
      }
      if (
        packagedPermissionSetId != null &&
        candidate.Profile != null &&
        candidate.Profile.UserLicense != null &&
        candidate.Profile.UserLicense.Name == SALESFORCE_USER_LICENSE
      ) {
        addAssignment(assignments, existingKeys, candidate.Id, packagedPermissionSetId);
      }
    }
    if (!assignments.isEmpty()) {
      Database.SaveResult[] results = Database.insert(assignments, false);
      if (Test.isRunningTest()) {
        for (Database.SaveResult result : results) {
          System.assert(
            result.isSuccess(),
            result.getErrors().isEmpty()
              ? 'permission set assignment failed'
              : result.getErrors()[0].getMessage()
          );
        }
      }
    }
  }

  private static void addAssignment(
    List<PermissionSetAssignment> assignments,
    Set<String> existingKeys,
    Id userId,
    Id permissionSetId
  ) {
    String key = assignmentKey(userId, permissionSetId);
    if (existingKeys.contains(key)) {
      return;
    }
    existingKeys.add(key);
    assignments.add(
      new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permissionSetId)
    );
  }

  private static String assignmentKey(Id userId, Id permissionSetId) {
    return String.valueOf(userId) + ':' + String.valueOf(permissionSetId);
  }
}
