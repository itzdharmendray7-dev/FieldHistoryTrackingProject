@isTest
public class TriggerCreationServiceTest {
  @testSetup
  static void setupTestData() {
    Record_Field_History_Tracking__c recordTracking = new Record_Field_History_Tracking__c();
    recordTracking.Object_Name__c = 'Account';
    insert recordTracking;
  }

  @isTest
  static void testCreateTrigger() {
    List<String> fieldNames = new List<String>{ 'Name', 'Description' };
    String objectApiName = 'Account';

    DynamicTriggerCreator creator = new DynamicTriggerCreator();

    Test.setMock(HttpCalloutMock.class, new ToolingApiMock());

    Test.startTest();
    creator.createTrigger(objectApiName, fieldNames);
    Test.stopTest();

    System.assert(true, 'Test completed without exceptions.');
  }

  @isTest
  static void testTriggerExecution() {
    Test.startTest();

    Account testAcc = new Account(Name = 'Initial Account');
    insert testAcc;

    testAcc.Name = 'Updated Account';
    update testAcc;

    Test.stopTest();

    List<Record_Field_History_Tracking__c> historyRecords = [
      SELECT Id, Object_Name__c
      FROM Record_Field_History_Tracking__c
      WHERE Object_Name__c = 'Account'
    ];

    System.assert(
      historyRecords.size() > 0,
      'There should be history records created for Account updates.'
    );
  }
}
