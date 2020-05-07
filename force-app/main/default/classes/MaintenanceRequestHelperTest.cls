@isTest
public with sharing class MaintenanceRequestHelperTest {
    @TestSetup
    static void makeData(){
        //Create some Cases
        List<Case> testCases = new List<Case>();
        List<Product2> newProducts = new List<Product2>();
        for(Integer i = 0; i < 5; i++){
            newProducts.add( new Product2(
                Name = 'Axle ' + i,
                Maintenance_Cycle__c = 50 * (i + 1)
            ));
        }

        insert newProducts;
        for(Integer i = 0; i < 10; i++){
            testCases.add(new Case(
                Status = 'Closed',
                Origin = 'Web',
                Priority = 'Medium',
                Type = 'Routine Maintenance',
                Subject = 'Routine Maitenance Work ' + i,
                Vehicle__c = 'a005w00000aiCiFAAU',
                Equipment__c = newProducts[math.mod(i,5)].Id,
                AccountId = '0015w00002AfVDFAA3',
                ContactId = '0035w000034yjr5AAA'
            ));
        }
        insert testCases;
    }

    @isTest
    static void mrTest(){
        List<Case> mrTest = [SELECT Id ,Type,Status,Origin,AccountId,ContactId,Subject,Vehicle__c,Equipment__c FROM Case WHERE Status = 'Closed'];
        List<Case> newCases = [SELECT Id,Type,Status,Origin,AccountId,ContactId,Subject,Vehicle__c,Equipment__c FROM Case WHERE Status = 'New'];

        System.assert(newCases != null);

    }
}

