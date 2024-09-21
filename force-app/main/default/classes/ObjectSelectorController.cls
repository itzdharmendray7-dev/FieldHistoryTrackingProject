public with sharing class ObjectSelectorController {
  @AuraEnabled(cacheable=true)
  public static List<EntityDefinition> getFieldHistoryEnabledObjects() {
    List<EntityDefinition> sObjects = new List<EntityDefinition>();

    for (EntityDefinition obj : [
      SELECT Label, QualifiedApiName
      FROM EntityDefinition
      WHERE IsCustomizable = TRUE
      ORDER BY Label ASC
    ]) {
      sObjects.add(obj);
    }
    System.debug(sObjects);
    System.debug(sObjects.size());
    return sObjects;
  }

  public class ObjectInfo {
    @AuraEnabled
    public String apiName { get; set; }
    @AuraEnabled
    public String label { get; set; }
  }
}
