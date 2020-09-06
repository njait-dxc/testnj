public class superSort {


	public static void sortList(List<SObject> items, String sortField, String order){/*
       
        
        Boolean isSortFieldReference = false;
        Map<Id,String> referenceName;
      
        if(items[0].getSObjectType().getDescribe().fields.getMap().get(sortField).getDescribe().getType().Name() == 'REFERENCE'){
            isSortFieldReference = true;
            referenceName = new Map<Id,String>();
            
          
            Set<Id> referenceIds = new Set<Id>();
            for(sObject s : items){
               referenceIds.add((Id)s.get(sortField));
            }
            
            String objectID = (String)items[0].get(sortField);
            String prefix = objectID.substring(0,3);
            String objectType;
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values()){
                if(prefix == s.getDescribe().getKeyPrefix()){
                    objectType = s.getDescribe().Name;
                }
            }
            
           
            String queryString = 'select Id, Name from ' + objectType + ' where ID IN :referenceIDs';
            for(sObject s : Database.query(queryString )){
                referenceName.put((Id)s.get('Id'),(String)s.get('Name'));
            }
        }
                
       
        List<cObject> resultList = new List<cObject>();
    
        
        Map<object, List<cObject>> objectMap = new Map<object, List<cObject>>();
        
        for(sObject ob : items){
            if(isSortFieldReference == false){
                if(objectMap.get(ob.get(sortField)) == null){ 
                    objectMap.put(ob.get(sortField), new List<cObject>()); 
                }
                cObject o = new cObject(ob);
                objectMap.get(ob.get(sortField)).add(o);
            }else{
                if(objectMap.get(referenceName.get((Id)ob.get(sortField))) == null){ 
                    objectMap.put(referenceName.get((Id)ob.get(sortField)), new List<cObject>()); 
                }
                cObject o = new cObject(ob);
                objectMap.get(referenceName.get((Id)ob.get(sortField))).add(o);
            }
        }
        
      
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
        
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
        
       
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(cObject ob : resultList){
                items.add(ob.obj);  
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i].obj);   
            }
        }
   */ }

}