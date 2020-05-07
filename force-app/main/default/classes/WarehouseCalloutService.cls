global class WarehouseCalloutService {
    //Make a GET callout to external service to get a list of equipment
    //that needs to be updated
    //JSON response returns the equipment records into a Collection Map
    //equipment records are upserted into salesforce
    @future(callout=true)
    public static void runWarehouseEquipmentSync(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        //If response is successful, parse the JSON
        if(response.getStatusCode() == 200){
            //Parse JSON as a List Object
   			List<Object> equipmentList = (List<Object>)JSON.deserializeUntyped(response.getBody());
            /*
                Your class maps the following fields: replacement part (always true), cost, current inventory, 
                lifespan, maintenance cycle, and warehouse SKU. Use the warehouse SKU as the external ID to identify
                 which equipment records to update within Salesforce.
            */
            //Create new Equipment object, and put generic object items into Object
            List<Product2> equipFromJSON = new List<Product2>();
            for(Object eq : equipmentList){
                Map<String,Object> equipMap = (Map<String,Object>)eq;
                equipFromJSON.add(new Product2(
                    Name = (String)equipMap.get('name'),
                    Replacement_Part__c = true,
                    Cost__c = (Decimal)equipMap.get('cost'),
                    Current_Inventory__c = (Integer)equipMap.get('quantity'),
                    Lifespan_Months__c = (Integer)equipMap.get('lifespan'),
                    Maintenance_Cycle__c = (Integer)equipMap.get('maintenanceperiod'),
                    Warehouse_SKU__c = (String)equipMap.get('sku'),
                    ExternalId = (String)equipMap.get('_Id')
                ));
            }
            upsert equipFromJSON;
        }
    }
}
