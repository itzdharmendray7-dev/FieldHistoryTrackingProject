public class DynamicTriggerCreator {
  public void createTrigger(String objectApiName, List<String> fieldNames) {
    String triggerBody = buildTriggerBody(objectApiName, fieldNames);

    ToolingAPI.createApexTrigger(objectApiName, triggerBody);
  }

  private String buildTriggerBody(
    String objectApiName,
    List<String> fieldNames
  ) {
    String triggerBody = '';
    triggerBody +=
      'trigger ' +
      objectApiName +
      '_HistoryTrigger on ' +
      objectApiName +
      ' (after insert, after update, after delete, after undelete) {\n' +
      '    SObjectHistoryTriggerDispatcher.dispatch(Trigger.operationType, \'' +
      objectApiName +
      '\');\n' +
      '}\n';

    System.debug('Trigger Body: ' + triggerBody);
    return triggerBody;
  }
}
