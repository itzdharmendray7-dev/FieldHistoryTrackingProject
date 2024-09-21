public with sharing class AccountHistoryTriggerHandler {
  private static Map<String, Schema.SObjectField> accountFieldsMap = Account.SObjectType.getDescribe()
    .fields.getMap();

  private static void createHistoryRecord(
    List<Record_Field_History_Tracking__c> historyRecords,
    Account acc,
    String changeType,
    String fieldName,
    Object oldValue,
    Object newValue
  ) {
    Record_Field_History_Tracking__c historyRecord = new Record_Field_History_Tracking__c();
    historyRecord.Object_Name__c = 'Account';
    historyRecord.Change_Type__c = changeType;
    historyRecord.Field_Name__c = fieldName;

    historyRecord.Old_Value__c = oldValue != null
      ? String.valueOf(oldValue)
      : null;
    historyRecord.New_Value__c = newValue != null
      ? String.valueOf(newValue)
      : null;

    historyRecords.add(historyRecord);
  }

  private static void processRecords(
    List<Account> accounts,
    String changeType,
    Map<Id, Account> oldAccountMap
  ) {
    List<Record_Field_History_Tracking__c> historyRecords = new List<Record_Field_History_Tracking__c>();

    Set<String> excludedFields = new Set<String>{
      'LastModifiedDate',
      'SystemModstamp'
    };

    for (Account acc : accounts) {
      Account oldAcc = oldAccountMap != null ? oldAccountMap.get(acc.Id) : null;

      for (Schema.SObjectField field : accountFieldsMap.values()) {
        String fieldName = field.getDescribe().getName();

        if (excludedFields.contains(fieldName)) {
          continue;
        }

        Object oldValue = oldAcc != null ? oldAcc.get(fieldName) : null;
        Object newValue = acc.get(fieldName);

        Boolean isDifferent = oldValue != newValue;
        Boolean isNotEmpty =
          newValue != null &&
          String.valueOf(newValue).trim() != '';

        if ((isDifferent && isNotEmpty) || changeType == 'Delete') {
          createHistoryRecord(
            historyRecords,
            acc,
            changeType,
            fieldName,
            oldValue,
            newValue
          );
        }
      }
    }

    if (!historyRecords.isEmpty()) {
      insert historyRecords;
    }
  }

  public static void handleAfterInsert(List<Account> newAccounts) {
    processRecords(newAccounts, 'Insert', null);
  }

  public static void handleAfterUpdate(
    List<Account> newAccounts,
    Map<Id, Account> oldAccountMap
  ) {
    processRecords(newAccounts, 'Update', oldAccountMap);
  }

  public static void handleAfterDelete(List<Account> oldAccounts) {
    processRecords(oldAccounts, 'Delete', null);
  }

  public static void handleAfterUndelete(List<Account> undeletedAccounts) {
    processRecords(undeletedAccounts, 'Undelete', null);
  }
}