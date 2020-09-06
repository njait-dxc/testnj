trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    Map<String, Set<Id>> sObjectsByType = new Map<String, Set<Id>>();
    List<sObject> sObjectsToBePushed = new List<sObject>();

    for (ContentDocumentLink contentDocumentLink : Trigger.new) {
        String sObjectType = String.valueOf(contentDocumentLink.LinkedEntityId.getSObjectType());
        if (sObjectsByType.containsKey(sObjectType)) {
            sObjectsByType.get(sObjectType).add(contentDocumentLink.LinkedEntityId);
        } else {
            sObjectsByType.put(sObjectType, new Set<Id>{contentDocumentLink.LinkedEntityId});
        }
    }

    for(String sObjectType : sObjectsByType.keySet()) {
        Set<Id> ids = sObjectsByType.get(sObjectType);
        String sObjectsById = 'SELECT Id FROM ' + sObjectType + ' where Id IN :ids';
        List<SObject> toBePushed = Database.query(sObjectsById);
        if (toBePushed.size() > 0) {
        	sObjectsToBePushed.addAll(toBePushed);
        }
    }

    if (sObjectsToBePushed.size() > 0) {
        JCFS.API.pushUpdatesToJira(sObjectsToBePushed, Trigger.old);
    }
}