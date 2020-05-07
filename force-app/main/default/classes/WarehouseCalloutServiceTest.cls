@isTest
public with sharing class WarehouseCalloutServiceTest {
    @isTest static void testGetWarehouseCallout(){
        //Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, new WarehouseHttpCalloutMock());
        //Call method to test
        Test.startTest();
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();
        List<Product2> allProducts = [SELECT Name, Warehouse_SKU__c FROM Product2];
        for(Product2 p : allProducts){
            System.debug('p is: ' + p);
            System.assertEquals('Generator 1000 kW', p.Name, 'Product Names are not equal');
            System.assertEquals('100003', p.Warehouse_SKU__c, 'Warehouse_SKU__c are not equal');
        }

    }
}
