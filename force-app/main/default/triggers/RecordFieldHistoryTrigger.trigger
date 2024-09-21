trigger RecordFieldHistoryTrigger on Account(
  after insert,
  after update,
  after delete,
  after undelete
) {
  AccountHistoryTriggerDispatcher.dispatch(Trigger.OperationType);
}
