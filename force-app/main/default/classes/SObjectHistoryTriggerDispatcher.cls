public with sharing class SObjectHistoryTriggerDispatcher {
  public static void dispatch(
    System.TriggerOperation operationType,
    String objectName
  ) {
    switch on operationType {
      when AFTER_INSERT {
        SObjectHistoryTriggerHandler.handleAfterInsert(Trigger.new, objectName);
      }
      when AFTER_UPDATE {
        SObjectHistoryTriggerHandler.handleAfterUpdate(
          Trigger.new,
          Trigger.oldMap,
          objectName
        );
      }
      when AFTER_DELETE {
        SObjectHistoryTriggerHandler.handleAfterDelete(Trigger.old, objectName);
      }
      when AFTER_UNDELETE {
        SObjectHistoryTriggerHandler.handleAfterUndelete(
          Trigger.new,
          objectName
        );
      }
    }
  }
}
