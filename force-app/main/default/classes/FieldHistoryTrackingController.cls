public with sharing class FieldHistoryTrackingController {
  @AuraEnabled(cacheable=true)
  public static List<EntityDefinition> getAllObjects() {
    List<EntityDefinition> allObjects = new List<EntityDefinition>();

    for (EntityDefinition obj : [
      SELECT Label, QualifiedApiName, KeyPrefix
      FROM EntityDefinition
      WHERE IsCustomizable = TRUE
      ORDER BY Label ASC
    ]) {
      allObjects.add(obj);
    }
    System.debug(allObjects);
    System.debug(allObjects.size());
    return allObjects;
  }

  @AuraEnabled
  public static void saveSelectedObjects(List<String> objectApiNames) {
    if (objectApiNames == null || objectApiNames.isEmpty()) {
      throw new AuraHandledException('No objects selected.');
    }

    List<Record_Field_History_Tracking__c> trackedObjects = new List<Record_Field_History_Tracking__c>();
    Set<String> existingObjectNames = new Set<String>();

    List<Record_Field_History_Tracking__c> existingTracked = [
      SELECT Object_Name__c
      FROM Record_Field_History_Tracking__c
      WHERE Object_Name__c IN :objectApiNames
    ];

    for (Record_Field_History_Tracking__c tracked : existingTracked) {
      existingObjectNames.add(tracked.Object_Name__c);
    }

    for (String apiName : objectApiNames) {
      if (!existingObjectNames.contains(apiName)) {
        Record_Field_History_Tracking__c tracked = new Record_Field_History_Tracking__c();
        tracked.Object_Name__c = apiName;
        trackedObjects.add(tracked);
      }
    }

    try {
      if (!trackedObjects.isEmpty()) {
        insert trackedObjects;
      } else {
        throw new AuraHandledException('No new objects to track.');
      }
    } catch (DmlException e) {
      throw new AuraHandledException('Error saving objects: ' + e.getMessage());
    }
  }

  public class ObjectInfo {
    @AuraEnabled
    public String apiName { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String idPrefix { get; set; }
    @AuraEnabled
    public String objectType { get; set; }
  }

  public class ObjectInfoComparator implements Comparator<ObjectInfo> {
    public Integer compare(ObjectInfo o1, ObjectInfo o2) {
      if (o1.label == null && o2.label == null) {
        return 0;
      } else if (o1.label == null) {
        return -1;
      } else if (o2.label == null) {
        return 1;
      }
      return o1.label.compareTo(o2.label);
    }
  }

  @AuraEnabled
  public static void createHistoryTriggers(
    String objectApiName,
    List<String> fieldNames
  ) {
    try {
      DynamicTriggerCreator creator = new DynamicTriggerCreator();
      creator.createTrigger(objectApiName, fieldNames);
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error creating trigger: ' + e.getMessage()
      );
    }
  }
}
