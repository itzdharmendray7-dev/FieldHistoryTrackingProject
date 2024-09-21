trigger AccountTrigger on Account(
  after insert,
  after update,
  after delete,
  after undelete
) {
  SObjectHistoryTriggerDispatcher.dispatch(
    Trigger.operationType,
    Account.sObjectType.getDescribe().getName()
  );
}
