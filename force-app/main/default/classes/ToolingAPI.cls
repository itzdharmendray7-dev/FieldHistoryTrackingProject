public class ToolingAPI {
  public static void createApexTrigger(
    String objectApiName,
    String triggerBody
  ) {
    String toolingApiUrl =
      URL.getCurrentRequestUrl().toExternalForm() +
      '/services/data/v61.0/tooling/sobjects/ApexTrigger/';

    String triggerPayload = JSON.serialize(
      new Map<String, Object>{
        'Name' => objectApiName + '_HistoryTrigger',
        'TableEnumOrId' => objectApiName,
        'Body' => triggerBody.replaceAll('\\n', '\\\\n').replaceAll('"', '\\"')
      }
    );

    HttpRequest req = new HttpRequest();
    req.setEndpoint(toolingApiUrl);
    req.setMethod('POST');
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    req.setHeader('Content-Type', 'application/json');
    req.setBody(triggerPayload);

    Http http = new Http();
    HttpResponse res = http.send(req);

    if (res.getStatusCode() == 201) {
      System.debug('Trigger created successfully');
    } else {
      System.debug('Error creating trigger: ' + res.getBody());
      System.debug('Status Code: ' + res.getStatusCode());
    }
  }
}
