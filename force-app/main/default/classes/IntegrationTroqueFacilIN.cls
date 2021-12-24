@RestResource(urlMapping='/troque-facil-in')
global with sharing class IntegrationTroqueFacilIN {
    @HttpPost
    global static void upsertCase() {

        Boolean hasError = false;

        List<TemplateDataIntegrationFields.Response> responseList = new List<TemplateDataIntegrationFields.Response>();

        Brand__c nikeBrand = [SELECT Id FROM Brand__c WHERE ExternalId__c = 'NIKE' AND Active__c = 'Active' LIMIT 1];

        try {

            System.debug('RestContext.request.requestBody => ' + RestContext.request.requestBody);

            String body = RestContext.request.requestBody.toString();

            Type requestType = Type.forName('IntegrationTroqueFacilIN.TroqueFacilIN');
            TroqueFacilIN request = (TroqueFacilIN) JSON.deserialize(RestContext.request.requestBody.toString(), requestType);

            Id reverseObjectTroqueFacilRTId = Schema.SObjectType.ObjetoPostagemReversa__c.getRecordTypeInfosByDeveloperName().get('Troque_Facil').getRecordTypeId();

            if(request != null && request.data != null) {

                Case newCase = new Case();
                
                newCase.Subject                     = 'Troque Fácil - ' + request.data?.reverse?.id;
                newCase.Marca__c                    = nikeBrand.Id;
                newCase.RecordTypeId                = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Troque_Facil').getRecordTypeId();
                newCase.Signature__c                = request.signature;
                newCase.Tracking_Ecommerce_Order__c = request.data?.ecommerce_order;
                newCase.Event_Name__c               = request.event_name;
                
                newCase.Customer_Name__c      = request.data?.customer?.first_name;
                newCase.Customer_Last_Name__c = request.data?.customer?.last_name;
                newCase.Customer_Email__c     = request.data?.customer?.email;
                newCase.Customer_Document__c  = request.data?.customer?.document.replaceAll('[^0-9]+', '');
                newCase.Customer_Phone__c     = request.data?.customer?.phone;

                newCase.Id_Reverse__c         = String.valueOf(request.data?.reverse?.id);
                // newCase.Reverse_Type__c       = request.data?.reverse?.reverse_type;
                newCase.Reverse_Type__c       = request.data?.reverse?.reverse_type_name;
                newCase.Ecommerce_Order_Id__c = String.valueOf(request.data?.reverse?.ecommerce_order_id);
                newCase.Total_Amount__c       = Decimal.valueOf(request.data?.reverse?.total_amount);
                newCase.Origin__c             = request.data?.reverse?.origin;
                newCase.Status_Id__c          = String.valueOf(request.data?.reverse?.status_id);
                newCase.Type__c               = request.data?.reverse?.type;
                newCase.Invoice__c            = request.data?.ecommerce_order;

                if(request.data?.reverse?.destination_data != null) {
                    newCase.Tracking_Expire_Date__c        = Datetime.valueOf(request.data?.reverse?.tracking?.expire_date);
                    // newCase.Tracking_Status__c             = request.data?.reverse?.tracking?.status;
                    // newCase.Tracking_Message__c            = request.data?.reverse?.tracking?.message;
                    newCase.Tracking_Authorization_Code__c = request.data?.reverse?.tracking?.authorization_code; // verificar se o código pode começar com 0
                    // newCase.Tracking_Code__c               = request.data?.reverse?.tracking?.tracking_code;
                }

                if(request.data?.reverse?.destination_data != null) {
                    newCase.Destination_Name__c             = request.data?.reverse?.destination_data.name;
                    newCase.Destination_Type__c             = request.data?.reverse?.destination_data.type;
                    newCase.Destination_Seller_info__c      = request.data?.reverse?.destination_data.seller_info;
                    newCase.Destination_Seller_id__c        = request.data?.reverse?.destination_data.seller_id;
                    newCase.Destination_Return_to_seller__c = request.data?.reverse?.destination_data.return_to_seller;
                }

                List<ObjetoPostagemReversa__c> postalObjectsToInsert = new List<ObjetoPostagemReversa__c>();
                String fullDescriptionCase = '';

                if(request.data?.reverse?.products != null && !request.data?.reverse?.products.isEmpty()) {
                
                    // iteração dos produtos (alterar para Objeto Postagem Reversa)
                
                    for(Product product : request.data?.reverse?.products) {

                        ObjetoPostagemReversa__c newPostalObject = new ObjetoPostagemReversa__c();

                        newPostalObject.Product_Order_Id_Reverse__c       = String.valueOf(product.order_id);
                        newPostalObject.Product_Price_Reverse__c          = Decimal.valueOf(product.price);
                        newPostalObject.Product_Selling_Price_Reverse__c  = Decimal.valueOf(product.selling_price);
                        newPostalObject.Product_SKU_Reverse__c            = product.sku;
                        newPostalObject.Product_Name_Reverse__c           = product.name;
                        newPostalObject.Product_Protocol_Reverse__c       = product.protocol;
                        newPostalObject.Product_Reverse_Action__c         = product.reverse_action;
                        // newPostalObject.Product_Reverse_Id__c             = String.valueOf(product.reverse_id);
                        newPostalObject.Product_Comments_Reverse__c       = product.comments;
                        newPostalObject.Ord_Product_Reverse__c            = request.data?.ecommerce_order;
                        newPostalObject.Qty_Product_Reverse__c            = product.qty;
                        newPostalObject.Requested_Qty_Produtct_Reverse__c = product.requested_qty;
                        newPostalObject.Received_Qty_Product_Reverse__c   = product.received_qty;
                        
                        newPostalObject.idObjetoColeta__c                 = 'TF-' + String.valueOf(product.reverse_id);
                        newPostalObject.RecordTypeId                      = reverseObjectTroqueFacilRTId;

                        if(product.reason != null) {
                            // newPostalObject.Product_Reason_should_approve_Reverse__c = product.reason.should_approve;
                            newPostalObject.Product_Reason_action_Reverse__c         = product.reason.action;
                            newPostalObject.Product_Reason_description_Reverse__c    = product.reason.description;
                        }

                        postalObjectsToInsert.add(newPostalObject);

                        // campo Description no Caso deve ser preenchido com:
                        // Nome do Produto: product.name
                        // Ação Reversa do Produto: product.reverse_action
                        // Comentários do Produto: product.comments
                        // de maneira iterada

                        fullDescriptionCase += 'Nome do Produto: ' + product.name;
                        fullDescriptionCase += '\nAção Reversa do Produto: ' +  product.reverse_action;
                        fullDescriptionCase += '\nComentários do Produto: ';
                        fullDescriptionCase += (product.comments == null? 'Não há comentários sobre o produto.' : product.comments) + '\n\n';
                    }

                    newCase.description = fullDescriptionCase;
                }

                insert newCase;

                if(!postalObjectsToInsert.isEmpty()) {
                    
                    for(ObjetoPostagemReversa__c newPostalObject : postalObjectsToInsert) {
                        newPostalObject.Caso__c = newCase.Id;
                    }

                    System.debug('postalObjectsToInsert => ' + JSON.serializePretty(postalObjectsToInsert));
                    
                    insert postalObjectsToInsert;
                }
            }

        } catch (Exception e) {
            hasError = true;
        }

        IntegrationUtils.WSLog('Case (Troque Fácil)', 'Inbound', RestContext.request.requestBody.toString(), JSON.serialize(responseList), hasError);
    }

    global class TroqueFacilIN {
        public String event_name;
        public String event_date;
        public Data data;
        public String signature; // Case.Signature__c
    }

    global class Data {
        public String ecommerce_order;
        public Customer customer;
        public Reverse reverse;
    }

    global class Customer {
        public String first_name; // Case.Customer_Name__c
        public String last_name; // Case.Customer_Last_Name__c
        public String email; // Case.Customer_Email__c
        public String document; // Case.Customer_Document__c
        public String phone; // Case.Customer_Phone__c
    }

    global class Reverse {
        public Integer id; // Case.Id_Reverse__c
        public String reverse_type; // Case.Reverse_Type__c ?
        public String reverse_type_name; // Case.Reverse_Type__c ?
        public Boolean courier_collect; // Case.Courier_Collect__c
        public Integer ecommerce_order_id; // Case.Ecommerce_Order_Id__c
        // public Object order_id; // Case.Order_Id__c
        // public Object courier_data; // Case.Courier_Data__c VAZIO (NULL)
        public String total_amount; // Case.Total_Amount__c
        // public Object invoice; // Case.Invoice__c
        public String origin; // Case.Origin__c
        public Integer status_id; // Case.Status_Id__c
        public String type; // Case.Type__c
        public DestinationData destination_data; // Case.Destination__c
        public List<Product> products; // Case.Product__
        public Tracking tracking; // Case.Tracking__
        public List<Refund> refunds; // Case.Refund_Product_Requests_Reverse ??
        // public EcommerceOrder ecommerce_order; //Case.Tracking_Ecommerce_Order ??
    }

    global class Refund {
        public String type;
        public String action;
    }

    global class DestinationData {
        public String name; // Case.Destination_Name__c
        public String type; // Case.Destination_Type__c
        public String seller_id; // Case.Destination_seller_id__c
        public String seller_info; // Case.Destination_seller_info__c
        public boolean return_to_seller; // Case.Destination_return_to_seller__c
    }

    global class Product {
        public Integer order_id; // Case.Product_Order_Id_Reverse__c
        public String price; // Case.Product_Price_Reverse__c
        public String selling_price; // Case.Product_Selling_Price_Reverse__c
        public String sku; // Case.Product_SKU_Reverse__c
        public String name; // Case.Product_Name_Reverse__c
        // public Object fraud; // Case.
        // public Object situation; // Case.Product_Situation_Reverse__c
        public String protocol; // Case.Product_Protocol_Reverse__c
        public String reverse_action; // Case.Product_Reverse_Action__c
        public String comments; // Case.Product_Comments_Reverse__c
        public Reason reason;
        public Integer qty;
        public Integer requested_qty;
        public Integer received_qty;
        public Integer reverse_id; // Case.Product_Reverse_Id__c
    }

    global class Reason {
        public Boolean should_approve; //Case.Product_Reason_should_approve_Reverse__c
        public String action; //Case.Product_Reason_action_Reverse__c
        public String description; //Case.Product_Reason_description_Reverse__c
    }

    global class Tracking {
        public String expire_date; // Case.Tracking_Expire_Date__c
        public Object status; // Case.Tracking_Status__c
        public Object message; // Case.Tracking_Message__c
        public Integer id; // Case.
        public String authorization_code; // Case.Tracking_Authorization_Code__c
        public Object tracking_code; // Case.Tracking_Code__c
    }
}