public with sharing class SObjectHistoryTriggerHandler {
  private static void createHistoryRecord(
    List<Record_Field_History_Tracking__c> historyRecords,
    String objectName,
    String changeType,
    String fieldName,
    Object oldValue,
    Object newValue
  ) {
    Record_Field_History_Tracking__c historyRecord = new Record_Field_History_Tracking__c();
    historyRecord.Object_Name__c = objectName;
    historyRecord.Change_Type__c = changeType;
    historyRecord.Field_Name__c = fieldName;

    historyRecord.Old_Value__c = oldValue != null
      ? String.valueOf(oldValue)
      : null;
    historyRecord.New_Value__c = newValue != null
      ? String.valueOf(newValue)
      : null;

    historyRecords.add(historyRecord);

    System.debug(
      'Creating history record for: ' + objectName + ', Field: ' + fieldName
    );
  }

  private static void processRecords(
    List<SObject> newRecords,
    String changeType,
    Map<Id, SObject> oldRecordMap,
    String objectName
  ) {
    List<Record_Field_History_Tracking__c> historyRecords = new List<Record_Field_History_Tracking__c>();

    Set<String> excludedFields = new Set<String>{
      'LastModifiedDate',
      'SystemModstamp'
    };

    Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(objectName);
    Map<String, Schema.SObjectField> fieldsMap = sobjectType.getDescribe()
      .fields.getMap();

    for (SObject record : newRecords) {
      SObject oldRecord = oldRecordMap != null
        ? oldRecordMap.get(record.Id)
        : null;

      for (Schema.SObjectField field : fieldsMap.values()) {
        String fieldName = field.getDescribe().getName();

        if (excludedFields.contains(fieldName)) {
          continue;
        }

        Object oldValue = oldRecord != null ? oldRecord.get(fieldName) : null;
        Object newValue = record.get(fieldName);

        Boolean isDifferent = oldValue != newValue;
        Boolean isNotEmpty =
          newValue != null &&
          String.valueOf(newValue).trim() != '';

        if ((isDifferent && isNotEmpty) || changeType == 'Delete') {
          createHistoryRecord(
            historyRecords,
            objectName,
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

  public static void handleAfterInsert(
    List<SObject> newRecords,
    String objectName
  ) {
    processRecords(newRecords, 'Insert', null, objectName);
  }

  public static void handleAfterUpdate(
    List<SObject> newRecords,
    Map<Id, SObject> oldRecordMap,
    String objectName
  ) {
    processRecords(newRecords, 'Update', oldRecordMap, objectName);
  }

  public static void handleAfterDelete(
    List<SObject> oldRecords,
    String objectName
  ) {
    processRecords(oldRecords, 'Delete', null, objectName);
  }

  public static void handleAfterUndelete(
    List<SObject> undeletedRecords,
    String objectName
  ) {
    processRecords(undeletedRecords, 'Undelete', null, objectName);
  }
}
