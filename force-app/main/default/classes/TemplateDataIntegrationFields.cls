global with sharing class TemplateDataIntegrationFields {

    public interface FieldData {
        List<String> getRequiredFields();
        String getFieldKey();
        String getFieldId();
        SObject serialize(Map<String, Id> lookups);
    }
        
    public interface FieldDataChild {
        List<String> getRequiredFields();
        String getFieldKey();
        String getFieldExternal();
        SObject serialize(Map<String, String> lookups);
        String getParentKey();
    }

    
    // Reclame Aqui (HugMe) Integration Classes

    global class ReclameAquiRetriveAllTicketINData {
        public List<ReclameAquiTicketINData> data;
    }

    global class ReclameAquiTicketINData{
        
        public Integer id;
        public String source_external_id;
        public Boolean can_like;
        //public Map<String,Object> company;
        //public Map<String,Object> user;
        //public Map<String,Object> account;
        public Boolean commentary;
        public String creation_date;
        public String insertion_date;
        public String complaint_title;
        public String last_modification_date;
        //public String closed_date;
        public String complaint_content;
        public String complaint_response_content;
        public String complaint_response_date;


        public ReclameAquiCustomerINData     customer; 
        // public List<ReclameAquiHistoricalINData>   historical;
        // public List<ReclameAquiInteractionsINData> interactions;

        
    }

    global class ReclameAquiCustomerINData{
        public List<String> birthday;
        public List<String> cpf;
        public List<String> rg;
        public List<String> gender;
        public List<String> email;
        public List<String> phone_numbers;
        public List<String> photo;
        public Integer id;
        public Integer duplicate_id;
        public String name;
        public List<String> cnpj;
        public String company_name;
        public List<CustomerCityData> city;
        public List<CustumerStateData> state;
        public String type;
        public List<String> tags; 
        public Integer pending_tickets_count;
    }

    public class CustomerCityData {
        public String id;
        public String name;
    }

    public class CustumerStateData {
        public String id;
        public String name;
        public String fs;
    }

    global class ReclameAquiHistoricalINData{
        public Map<String,Object> user;
        public Map<String,Object> auto;
        public Integer id;
        public String creation_date;
        public Map<String,Object> type;
    }

    global class ReclameAquiInteractionsINData{
        public String ticket_interaction_id;
        public Integer ticket_interaction_type_id;
        public String ticket_interaction_name;
        public String customer_id;
        public String responsible_id;
        public String responsible_name;
        public String message;
        public Boolean privacy;
        public String creation_date;
        public String modification_date;
        public Boolean delivered;
        public Boolean readed;
        public Boolean visualized;
        public String video;
        public String picture;
        public List<Map<String,Object>> details;
    }
    

    // iHub Integration Classes
    
    global class RefundOUTData {
        public String  type;
        public String  protocol;
        public Decimal refundValue;
        public String  originOrderId;
        
        public BankAccountOUTData bankAccount; 
    }

    global virtual class BankAccountOUTData {
        public String document;
    }

    global virtual class BankInvoiceOUTData extends BankAccountOUTData {
        public String account;
        public String accountDigit;
        public String bankAgency;
        public String bankCode;
        public String customerName;
        public String documentType;
        public String accountType;
    }
    

    
    global class CaseINData implements FieldData {
        public String protocolType;
        public String invoiceNumber;
        public String erpOrderId;
        public String originOrderId;
        public String subject;
        public String origem;
        public String mlnCaseId;

        public AccountINData customer;
        List<OrderItemINData> items;

        public Case serialize(Map<String, Id> lookups){
            Case caseObj = new Case();

            caseObj.ProtocolType__c = this.protocolType;
            caseObj.Subject         = this.subject;
            caseObj.Origin          = this.origem;
            
            // caseObj.AccountId       = lookups.get('Account' + this.customer.document);
            caseObj.AccountId       = lookups.get('Account' + this.customer.document.replaceAll('[^0-9]+', ''));
            caseObj.Order__c        = lookups.get('Order' + this.erpOrderId);

            caseObj.ExternalCaseId__c = this.mlnCaseId;

            caseObj.Description = 'Os seguintes itens estão afetados pela ruptura de estoque: \n';

            for(OrderItemINData item : items) {
                caseObj.Description += item.name + ' \n';
            }

            return caseObj;
        }

        public CaseINData(){}

        public List<String> getRequiredFields(){
            return new List<String>{
                'AccountId',
                'Order__c',
                'Subject'
            };
        }
        public String getFieldKey(){
            return 'CaseNumber';
        }
        public String getFieldId(){
            return 'Id';
        }
    }

    global class InvoiceINData implements FieldData{
        public String storeCode;
        public String storeId;
        public String status;
        public String invoiceNumber;
        public String invoiceSerie;
        public String operationType;
        public String emissionDate;
        public Boolean isOut;
        public Integer transId;
        public String additionalInfo;
        public String salesChannel;
        public String businessUnitCode;
        public String eventCode;
        
        // atualização status - 20/09
        public String eletronicKey;
        public String invoiceSerialNumber;
        public String integrationType;
        
        //atualização de status reversa - campo deve ser alterado (nome apenas para teste)
        public String caseCode;
        
        public String orderExternalId;

        public List<InvoiceItemsINData> items;

        public SefazInvoiceINData sefaz;
        public EmitterInvoiceINData emitter;
        public ReceiverInvoiceINData receiver;
        public TotalInvoiceINData total;
        public ShippingCompanyInvoiceINData shippingCompany;
        public OrderInvoiceINData order;

        public Invoice__c serialize(Map<String, Id> lookups){
            Invoice__c invoice = new Invoice__c();

            invoice.Order__c               = lookups.get('Order' + this.orderExternalId);

            invoice.ExternalId__c          = this.sefaz?.key;
            invoice.EmissionDate__c        = this.emissionDate != null ? (Datetime) JSON.deserialize('"' + this.emissionDate + '"', datetime.class) : null;
            invoice.InvoiceNumber__c       = this.invoiceNumber;
            
            if(integrationType == 'StatusIN') { 

                invoice.EletronicKey__c     = this.eletronicKey;
                invoice.InvoiceSerie__c     = this.invoiceSerialNumber;

            } else {
    
                invoice.OrderInternalNumber__c = this.order.internalNumber;

                invoice.StoreCode__c      = this.storeCode;
                invoice.Status__c         = this.status;
                invoice.InvoiceSerie__c   = this.invoiceSerie;
                invoice.OperationType__c  = this.operationType;
                invoice.IsOut__c          = this.isOut;
                invoice.TransId__c        = String.valueOf(this.transId);
                invoice.AdditionalInfo__c = this.additionalInfo;
                invoice.SalesChannel__c   = this.salesChannel;

                invoice.SefazKey__c                           = this.sefaz.key;
                invoice.SefazOriginalKey__c                   = this.sefaz.originalKey;
                invoice.SefazStatus__c                        = this.sefaz.status;
                invoice.SefazAuthorizationDate__c             = this.sefaz.authorizationDate != null ? (Datetime) JSON.deserialize('"' + this.sefaz.authorizationDate + '"', datetime.class) : null;
                invoice.SefazProtocol__c                      = this.sefaz.protocol;
                invoice.SefazCancellationProtocol__c          = this.sefaz.cancellationProtocol;
                invoice.SefazCancellationAuthorizationDate__c = this.sefaz.cancellationAuthorizationDate != null ? (Datetime) JSON.deserialize('"' + this.sefaz.cancellationAuthorizationDate + '"', datetime.class) : null;
                invoice.SefazGnreValue__c                     = String.valueOf(this.sefaz.gnreValue);
                invoice.SefazFreigthType__c                   = this.sefaz.freigthType;

                invoice.EmitterDocument__c          = this.emitter.document;
                invoice.EmitterDocumentType__c      = this.emitter.documentType;
                invoice.EmitterStateInscription__c  = this.emitter.stateInscription;
                invoice.EmitterCorporateName__c     = this.emitter.corporateName;
                invoice.EmitterTradeName__c         = this.emitter.tradeName;
                invoice.EmitterStreet__c            = this.emitter.street;
                //invoice.EmitterNumber__c            = this.emitter.number;   
                invoice.EmitterNeighborhood__c      = this.emitter.neighborhood;
                invoice.EmitterCityName__c          = this.emitter.cityName;
                invoice.EmitterState__c             = this.emitter.state;
                invoice.EmitterZipCode__c           = this.emitter.zipCode;
                invoice.EmitterCountryName__c       = this.emitter.countryName;
                invoice.EmitterPhone__c             = this.emitter.phone;
                invoice.EmitterEmail__c             = this.emitter.email;

                invoice.ReceiverDocument__c         = this.receiver.document;            
                invoice.ReceiverStateInscription__c = this.receiver.stateInscription;
                invoice.ReceiverDocumentType__c     = this.receiver.documentType;
                invoice.ReceiverName__c             = this.receiver.name;
                invoice.ReceiverStreet__c           = this.receiver.street;
                //invoice.ReceiverNumber__c           = this.receiver.;
                invoice.ReceiverNeighborhood__c     = this.receiver.neighborhood;
                invoice.ReceiverCityName__c         = this.receiver.cityName;
                invoice.ReceiverState__c            = this.receiver.state;
                invoice.ReceiverZipCode__c          = this.receiver.zipCode;   
                invoice.ReceiverCountryName__c      = this.receiver.countryName;
                invoice.ReceiverPhone__c            = this.receiver.phone;
                invoice.ReceiverEmail__c            = this.receiver.email;
    
                invoice.TotalIcmsBaseValue__c       = this.total.icmsBaseValue;
                invoice.TotalIcms__c                = this.total.icmsValue;
                invoice.TotalIcmsBaseST__c          = this.total.icmsBaseST;
                invoice.TotalIcmsValueST__c         = this.total.icmsValueST;
                invoice.TotalProductsValue__c       = this.total.productsValue;
                invoice.TotalFreigth__c             = this.total.freigth;
                invoice.TotalInsurance__c           = this.total.insurance;
                invoice.TotalDiscount__c            = this.total.discount;
                invoice.TotalIpiValue__c            = this.total.ipiValue;
                invoice.TotalPisValue__c            = this.total.pisValue;
                invoice.TotalCofinsValue__c         = this.total.cofinsValue;
                invoice.TotalInvoiceValue__c        = this.total.invoiceValue;
                invoice.TotalQuantity__c            = this.total.quantity;
                invoice.TotalDistinctItem__c        = this.total.distinctItem;
                invoice.TotalVolumes__c             = this.total.volumes;
                invoice.TotalGrossWeight__c         = this.total.grossWeight;
                invoice.TotalNetWeight__c           = this.total.netWeight;

                invoice.ShippingName__c             = this.shippingCompany.name;
                invoice.ShippingDocument__c         = this.shippingCompany.document;
                invoice.ShippingDocumentType__c     = this.shippingCompany.documentType;
                invoice.ShippingStateInscription__c = this.shippingCompany.stateInscription;
                invoice.ShippingStreet__c           = this.shippingCompany.street;
                //invoice.ShippingNumber__c           = this.shippingCompany.;
                invoice.ShippingNeighborhood__c     = this.shippingCompany.neighborhood;
                invoice.ShippingCity__c             = this.shippingCompany.city;
                invoice.ShippingState__c            = this.shippingCompany.state;
                invoice.ShippingZipCode__c          = this.shippingCompany.zipCode;

                invoice.OrderInternalNumber__c = this.order.internalNumber; 
                invoice.OrderOriginNumber__c   = this.order.originNumber;
            }

            return invoice;
        }

        public InvoiceINData(){}
        public List<String> getRequiredFields(){
            return new List<String>{
            };
        }
        public String getFieldKey(){
            return 'ExternalId__c';
        }
        public String getFieldId(){
            return 'Id';
        }
        
    }
    global class InvoiceItemsINData implements FieldData{
        public TaxesItemsInvoiceINData taxes;

        public String productId;
        public String ean;
        public String description;
        public String ncm;
        public String cfop;
        public String unitOfMeasurement;
        public Integer quantityFiscal;
        public Integer quantityPhisical;
        public Double unitaryValue;
        public Double totalValue;
        public Double freightValue;
        public Double discountValue;
        //public Integer number;
        public String serialNumber;
        public String barcode;

        public String sku;
        public Integer index;

        public String invoiceId;
        public String externalId;

        public InvoiceItems__c serialize(Map<String, Id> lookups) {
            InvoiceItems__c invoiceItems = new InvoiceItems__c();

            invoiceItems.ExternalID__c        = this.externalId; //alterar para sku
            invoiceItems.Name                 = String.valueOf(this.index);
            invoiceItems.EAN__c               = this.ean;
            invoiceItems.Invoice__c           = lookups.get('Invoice' + this.invoiceId);
            invoiceItems.Barcode__c           = this.barcode;
            invoiceItems.Cfop__c              = this.cfop;
            invoiceItems.Description__c       = this.description;
            invoiceItems.DiscountValue__c     = this.discountValue;
            invoiceItems.FreightValue__c      = this.freightValue;
            invoiceItems.Ncm__c               = this.ncm;
            invoiceItems.QuantityFiscal__c    = this.quantityFiscal;
            invoiceItems.QuantityPhisical__c  = this.quantityPhisical;
            invoiceItems.SerialNumber__c      = String.valueOf(this.serialNumber);
            invoiceItems.UnitaryValue__c      = this.unitaryValue;
            invoiceItems.UnitOfMeasurement__c = this.unitOfMeasurement;
            invoiceItems.TotalValue__c        = this.totalValue;

            // cofins
            invoiceItems.CofinsBase__c         = this.taxes?.cofins.cofinsBase;
            invoiceItems.CofinsAliquot__c      = this.taxes?.cofins.cofinsAliquot;
            invoiceItems.CofinsTaxSituation__c = this.taxes?.cofins.taxSituation;
            invoiceItems.CofinsValue__c        = this.taxes?.cofins.cofinsValue;

            // fcp
            invoiceItems.fcpAliquot__c = this.taxes?.icms?.fcpAliquot;
            invoiceItems.fcpBase__c    = this.taxes?.icms?.fcpBase;
            invoiceItems.fcpValue__c   = this.taxes?.icms?.fcpValue;
            
            //icms
            invoiceItems.icmsAliquot__c      = this.taxes?.icms?.icmsAliquot;
            invoiceItems.icmsBase__c         = this.taxes?.icms?.icmsBase;
            invoiceItems.icmsTaxSituation__c = this.taxes?.icms?.taxSituation;
            invoiceItems.icmsValue__c        = this.taxes?.icms?.icmsValue;

            //ipi
            invoiceItems.IpiAliquot__c      = this.taxes?.ipi?.ipiAliquot;
            invoiceItems.IpiBase__c         = this.taxes?.ipi?.ipiBase;
            invoiceItems.IpiTaxSituation__c = this.taxes?.ipi?.taxSituation;
            invoiceItems.IpiValue__c        = this.taxes?.ipi?.ipiValue;

            //pis
            invoiceItems.pisAliquot__c      = this.taxes?.pis?.pisAliquot;
            invoiceItems.pisBase__c         = this.taxes?.pis?.pisBase;
            invoiceItems.pisTaxSituation__c = this.taxes?.pis?.taxSituation;
            invoiceItems.pisValue__c        = this.taxes?.pis?.pisValue;

            return invoiceItems;
        }

        public List<String> getRequiredFields() {
            return new List<String>{
            };
        }
        public String getFieldKey() {
            return 'EAN__c';
        }
        public String getFieldId() {
            return 'Id';
        }
    }

    global class TaxesItemsInvoiceINData {
        public IcmsInvoiceINData icms;
        public PisInvoiceINData pis;
        public CofinsInvoiceINData cofins;
        public IpiInvoiceINData ipi;
    }

    global class IcmsInvoiceINData {
        public Double icmsBase;
        public Double icmsAliquot;
        public Double icmsValue;
        public Double sharingValueOrigin;
        public Double sharingValueDestiny;
        public String sharingAliquotOrigin;
        public String sharingAliquotDestiny;
        public String taxSituation;
        public Double fcpAliquot;
        public Double fcpBase;
        public Double fcpValue;
        public Double sharingBaseValueDestiny;
    }

    global class PisInvoiceINData {
        public Double pisBase;
        public Double pisAliquot;
        public Double pisValue;
        public String taxSituation;
    }

    global class CofinsInvoiceINData {
        public Double cofinsBase;
        public Double cofinsAliquot;
        public Double cofinsValue;
        public String taxSituation;
    }

    global class IpiInvoiceINData {
        public Double ipiBase;
        public Double ipiAliquot;
        public Double ipiValue;
        public String taxSituation;
    }

    global class SefazInvoiceINData {
        public String key;
        public String originalKey;
        public String status;
        public String authorizationDate;
        public String protocol;
        public String cancellationProtocol;
        public String cancellationAuthorizationDate;
        public Double gnreValue;
        public String freigthType;
    }

    global class EmitterInvoiceINData {
        public String document;
        public String documentType;
        public String stateInscription;
        public String corporateName;
        public String tradeName;
        public String street;
        //public String number;
        public String neighborhood;
        public Integer cityNumber;
        public String cityName;
        public String state;
        public String zipCode;
        public Integer countryNumber;
        public String countryName;
        public String phone;
        public String email;
    }

    global class ReceiverInvoiceINData {
        public String personType;
        public String document;
        public String stateInscription;
        public String documentType;
        public String name;
        public String street;
        //public String number;
        public String neighborhood;
        public Integer cityNumber;
        public String cityName;
        public String state;
        public String zipCode;
        public Integer countryNumber;
        public String countryName;
        public String phone;
        public String email;
    }

    global class TotalInvoiceINData {
        public Double icmsBaseValue;
        public Double icmsValue;
        public Double icmsBaseST;
        public Double icmsValueST;
        public Double productsValue;
        public Double freigth;
        public Double insurance;
        public Double discount;
        public Double ipiValue;
        public Double pisValue;
        public Double cofinsValue;
        public Double invoiceValue;
        public Integer quantity;
        public Integer distinctItem;
        public Integer volumes;
        public Double grossWeight;
        public Double netWeight;
    }

    global class ShippingCompanyInvoiceINData {
        public String name;
        public String document;
        public String documentType;
        public String stateInscription;
        public String street;
        //public String number;
        public String neighborhood;
        public String city;
        public String state;
        public String zipCode;
    }

    global class PaymentsOrderInvoiceINData {
        public Boolean isBill;
        public String paymentMethod;
        public String stallments;
        public String installments;
        public String nsu;
        public String brand;
        public Double value;
        //public Integer dueDate;
        public String financialRelease;
    }

    global class OrderInvoiceINData {
        public String internalNumber;
        public String originNumber;
        //public String purchaseDate;
        //public String estimateShippingDate;
        public List<PaymentsOrderInvoiceINData> payments;
    }

    
    global virtual class CaseOUTData {
        public String protocolType;
        public String externalProtocolId;
        public Integer invoiceNumber;
        public String erpOrderId;
        public String description;
        // public ExchangeOrderCaseOUTData exchangeOrder;

        public AccountCaseOUTData customer;
        public List<ItemsCaseOUTData> items;

        public CaseOUTData(Invoice__c invoiceOUT, Order orderOUT, Case caseOUT) {

            this.protocolType = caseOUT.ProtocolType__c;

            System.debug('invoiceOUT => ' + invoiceOUT);
            
            this.externalProtocolId = 'SF-' + caseOUT.CaseNumber;
            this.invoiceNumber      = invoiceOUT != null? Integer.valueOf(invoiceOUT.InvoiceNumber__c) : 6;
            //this.invoiceNumber      = 98765;
            // this.erpOrderId         = String.valueOf(orderOUT.NumeroPedidoERP__c);
            this.erpOrderId         = orderOUT.numeroPedidoERP__c;
            this.description        = 'Tipo: ' + String.valueOf(caseOUT.Type) + '\n';
            this.description        += 'Motivo: ' + String.valueOf(caseOUT.Reason__c) + '\n';
            this.description        += 'Sub-Motivo: ' + String.valueOf(caseOUT.SubReason__c) + '\n';
            this.description        += 'Descrição: ' + String.valueOf(caseOUT.Description);

            if(this.protocolType == 'exchange') {
                // ExchangeOrderCaseOUTData exchangeOrder = new ExchangeOrderCaseOUTData();
                // exchangeOrder.orderId = '61aa8641713b6f002c64b303';
                // exchangeOrder.originOrderId = '8012f000000x476AAA';
                // exchangeOrder.origin = 'ihub';
                
                // this.exchangeOrder = exchangeOrder;
            }

            System.debug('Protocol Type ' + this.protocolType);
            System.debug('External Protocol Id ' + this.invoiceNumber);
            System.debug('Invoice Number ' + this.invoiceNumber);
            System.debug('erpOrderId ' + this.invoiceNumber);
            System.debug('Description ' + this.description);
        }
    }

    global class ExchangeCaseOUTData extends CaseOUTData {
        public ExchangeOrderCaseOUTData exchangeOrder;

        public ExchangeCaseOUTData(Invoice__c invoiceOUT, Order orderOUT, Case caseOUT) {

            super(invoiceOUT, orderOUT, caseOUT);
        
            if(this.protocolType == 'exchange') {
                ExchangeOrderCaseOUTData exchangeOrder = new ExchangeOrderCaseOUTData();
                exchangeOrder.orderId = '61aa8641713b6f002c64b303';
                exchangeOrder.originOrderId = '8012f000000x476AAA';
                exchangeOrder.origin = 'ihub';
                
                this.exchangeOrder = exchangeOrder;
            }
        }
    }

    global class ExchangeOrderCaseOUTData {
        public String orderId;
        public String originOrderId;
        public String origin;

        public ExchangeOrderCaseOUTData() {}
    }

    global class AccountCaseOUTData {
        public String email;
        public String document;
        public String type;

        public AccountCaseOUTData(Account accountCaseOUT) {
            this.email  = accountCaseOUT.Email__c;
            if (accountCaseOUT.CPF__c != null || accountCaseOUT.CPF__c != '') {
                this.document = accountCaseOUT.CPF__c;
                this.type     = 'cpf';
            } else if(accountCaseOUT.CNPJ__c != null || accountCaseOUT.CNPJ__c != '') {
                this.document = accountCaseOUT.CNPJ__c;
                this.type     = 'cnpj';
            }
            System.debug('email ' + this.email);
            System.debug('CPF ou CNPJ' + this.document);
            System.debug('Type Document ' + this.type);
        }
    }

    global class ItemsCaseOUTData {
        public String sku;
        public Integer quantity;
        public Integer price;

        public ItemsCaseOUTData(OrderItem orderItemCaseOUT) {
            this.sku      = orderItemCaseOUT.Sku__c;
            this.quantity = Integer.valueOf(orderItemCaseOUT.Quantity);
            this.price    = Integer.valueOf(orderItemCaseOUT.UnitPrice);
            System.debug('Sku ' + this.sku);
            System.debug('Quantity ' + this.quantity);
            System.debug('Price ' + this.price);
        }
    }
    

    
    global class OrderOUTData{
        public String originOrderId;
        public String orderMasterId;
        public String creationDate;
        public Double value;
        public String status;
        public String visitorDevice;
        public String omniChannelId;
        public String orderClassification;
        public String sellerCode;
        public String salesOperatorName;
        public String sellerName;
        public String customData;
        public String approvalDate;

        public String externalOrderId;

        public TotalsOUTData totals;
        public AccountOUTData customer;
        public List<ItemsOUTData> items;
        public AddressBillingOUTData billingAddress;
        public AddressDeliveryOUTData deliveryAddress;
        public List<LogisticInformationOUTData> logisticInfo;
        public List<PaymentsOUTData> payments;

        public OrderOUTData (Order orderOUT) {
            this.originOrderId           = orderOUT.NumeroPedidoERP__c;
            this.orderMasterId           = orderOUT.OriginalOrderId;
            this.creationDate            = orderOUT.creationDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'America/Sao_Paulo') + 'Z';
            this.approvalDate            = this.creationDate;
            this.value                   = orderOUT.OrderTotals__c;
            this.status                  = orderOUT.status;
            this.externalOrderId         = this.originOrderId;
            //this.visitorDevice
            //this.omniChannelId           
            //this.orderClassification
            //this.sellerCode 
            //this.salesOperatorName
            //this.sellerName
            //this.customData

            this.totals                  = new TotalsOUTData();
            this.totals.items            = orderOUT.TotalItems__c + orderOUT.DiscountSUM__c;
            this.totals.tax              = orderOUT.tax__c;
            this.totals.discounts        = orderOUT.DiscountSUM__c;
            this.totals.shipping         = orderOUT.Shipping__c;
            System.debug('VALOR DO FRETE '  + orderOUT.Shipping__c);
            System.debug('this.totals.shipping ' + this.totals.shipping);
        }
    }

    global class TotalsOUTData {
        public Double items;
        public Double discounts;
        public Double shipping;
        public Double tax;
    }

    global class AccountOUTData {
        public List<PhoneINData> phones;
        public String email;
        public Boolean isCorporate;
        public String firstName;
        public String lastName;
        public String document;
        public String documentType;

        public AccountOUTData (Account accountOUT) {
            this.document        = accountOUT.ExternalId__c;
            this.email           = accountOUT.Email__c;
            this.firstName       = String.isBlank(accountOUT.FirstName__c)? accountOUT.Name.substringBefore(' ') : accountOUT.FirstName__c;
            this.lastName        = String.isBlank(accountOUT.LastName__c)? accountOUT.Name.substringAfter(' ') : accountOUT.LastName__c;

            if (accountOUT.CPF__c != null) {
                this.documentType = 'cpf';
            } else {
                this.documentType = 'cnpj';
            }

            this.isCorporate = this.documentType == 'cpf'? false : true;

            this.phones = new List<PhoneINData>();

            PhoneINData phoneInData = new PhoneINData();
            phoneInData.phone = accountOut.phone;
            phoneInData.type  = accountOut.phoneType__c;

            this.phones.add(phoneInData);
        }
    }

    global class ItemsOUTData {
        public String sku;
        public String name;
        public Integer quantity;
        public Double listPrice;
        public Double price;
        public Double sellingPrice;
        public String preSaleDate;
        public Boolean isGift;
        public Boolean isSubsidized;
        public String imageUrl;
        public String detailUrl;

        // public List<PromotionOUTData> promotions;
        // public List<ComponentOUTData> components;
        // public List<CustomizationOUTData> customizations;

        public ItemsOUTData (OrderItem orderItemsOUT) {
            this.sku          = orderItemsOUT.Sku__c;
            this.name         = orderItemsOUT.Description;
            this.quantity     = Integer.valueOf(orderItemsOUT.Quantity);
            this.listPrice    = orderItemsOUT.ListPrice;
            this.price        = orderItemsOUT.Preco__c;
            this.sellingPrice = orderItemsOUT.UnitPrice;
            this.preSaleDate  = String.valueOf(orderItemsOUT.PreSaleDate__c);
            this.isGift       = orderItemsOUT.IsGift__c;
            this.isSubsidized = orderItemsOUT.IsSubsidized__c;
            this.imageUrl     = orderItemsOUT.ImageUrl__c;
            this.detailUrl    = orderItemsOUT.DetailUrl__c;
        }
    }

    global class AddressBillingOUTData {
        public String addressType;
        //public String receiverName;
        public String postalCode;
        public String city;
        public String state;
        public String country;
        public String street;
        public String addressNumber;
        public String neighborhood;
        public String complement;
        public String reference;

        public AddressBillingOUTData (Address__c addeessOUT) {
            this.addressType   = addeessOUT.AddressType__c;
            //this.receiverName  = addeessOUT.ReceiverName__c;
            this.postalCode    = addeessOUT.PostalCode__c;
            this.city          = addeessOUT.City__c;
            this.state         = addeessOUT.State__c;
            this.street        = addeessOUT.Street__c;
            this.country       = addeessOUT.Country__c;
            this.addressNumber = addeessOUT.Number__c;
            this.neighborhood  = addeessOUT.Neighborhood__c;
            this.complement    = addeessOUT.Complement__c;
            this.reference     = addeessOUT.Reference__c;
        }
    }

    global class AddressDeliveryOUTData {
        public String addressType;
        public String receiverName;
        public String postalCode;
        public String city;
        public String state;
        public String country;
        public String street;
        public String addressNumber;
        public String neighborhood;
        public String complement;
        public String reference;

        public AddressDeliveryOUTData (Address__c addeessOUT) {
            this.addressType   = addeessOUT.AddressType__c;
            this.receiverName  = addeessOUT.ReceiverName__c;
            this.postalCode    = addeessOUT.PostalCode__c;
            this.city          = addeessOUT.City__c;
            this.state         = addeessOUT.State__c;
            this.street        = addeessOUT.Street__c;
            this.country       = addeessOUT.Country__c;
            this.addressNumber = addeessOUT.Number__c;
            this.neighborhood  = addeessOUT.Neighborhood__c;
            this.complement    = addeessOUT.Complement__c;
            this.reference     = addeessOUT.Reference__c;
        }
    }

    global class LogisticInformationOUTData {
        public PickupStoreInfoOUTData pickupStoreInfo;
        public Integer itemIndex;
        public String logisticContract;
        public Double price;
        public Double listPrice;
        public Double sellingPrice;
        public String deliveryCompany;
        public String shippingEstimate;
        public String shippingEstimateDate;
        public String deliveryChannel;

        public LogisticInformationOUTData (LogisticInformation__c logisticInfoOUT) {
            this.logisticContract               = logisticInfoOUT.logisticContract__c;
            this.price                          = logisticInfoOUT.price__c;
            this.listPrice                      = logisticInfoOUT.listPrice__c;
            this.sellingPrice                   = logisticInfoOUT.sellingPrice__c;
            this.deliveryCompany                = logisticInfoOUT.deliveryCompany__c;
            this.shippingEstimate               = logisticInfoOUT.shippingEstimate__c;
            this.shippingEstimateDate           = logisticInfoOUT.shippingEstimateDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS', 'America/Sao_Paulo') + 'Z';
            this.deliveryChannel                = logisticInfoOUT.deliveryChannel__c;
            System.debug('Price ' + logisticInfoOUT.price__c);
            System.debug('listPrice ' + logisticInfoOUT.listPrice__c);
            System.debug('sellingPrice__c ' + logisticInfoOUT.sellingPrice__c);
            this.pickupStoreInfo                = new PickupStoreInfoOUTData();
            this.pickupStoreInfo.additionalInfo = logisticInfoOUT.additionalInfo__c;
            this.pickupStoreInfo.address        = logisticInfoOUT.address__c;
            this.pickupStoreInfo.dockId         = String.valueOf(logisticInfoOUT.dockId__c);
            this.pickupStoreInfo.friendlyName   = logisticInfoOUT.friendlyName__c;
            this.pickupStoreInfo.isPickupStore  = logisticInfoOUT.isPickupStore__c;
        }
    }

    global class PickupStoreInfoOUTData {
        public String additionalInfo;
        public String address;
        public String dockId;
        public String friendlyName;
        public Boolean isPickupStore;
    }

    global class PaymentsOUTData {
        public String paymentId;
        public String originPaymentId;
        public Double value;
        public Integer interestAmount;
        public Integer interestRate;
        public String paymentGroup;
        public String dueDate;
        public Integer installments;
        public String tid;
        public String redemptionCode;        
        public String url;
        public String cardBrand;
        public String firstDigits;
        public String lastDigits;
        public String cardHoldersName;

        public PaymentsOUTData (Payments__c paymentsOUT) {
            this.paymentId       = paymentsOUT.Id;
            this.originPaymentId = paymentsOUT.originPaymentId__c;
            this.value           = paymentsOUT.value__c;
            this.interestAmount  = Integer.valueOf(paymentsOUT.interestAmount__c);
            this.interestRate    = Integer.valueOf(paymentsOUT.interestRate__c);
            this.paymentGroup    = paymentsOUT.Grupo__c;
            this.dueDate         = String.valueOf(paymentsOUT.dueDate__c);
            this.installments    = Integer.valueOf(paymentsOUT.installments__c);
            this.tid             = paymentsOUT.tid__c;
            this.redemptionCode  = paymentsOUT.redemptionCode__c;
            this.url             = '';
            this.cardBrand       = paymentsOUT.cardBrand__c;
            this.firstDigits     = paymentsOUT.firstDigits__c;
            this.lastDigits      = paymentsOUT.lastDigits__c;
            this.cardHoldersName = paymentsOUT.cardHoldersName__c;       
        }
    }

    global class OrderINData implements FieldData {
        public String originOrderId;
        public String internalOrderId;
        public String creationDate;
        public Double value;
        public String status;
        public String visitorDevice;
        public String orderType;
        public String orderClassification;
        public String omniChannelId;
        public String salesOperatorName;
        public String salesChannel;
        public String salesLocation;
        public String salesOperatorCode;
        public String externalOrderId;
        
        public String sellerName;
        public String sellerCode;
        public String storeCode;
        public String storeId;

        public String origin;
        public String affiliateId;

        public TotalsINData totals;
        public AccountINData customer;
        public AddressINData billingAddress;
        public AddressINData deliveryAddress;
        public List<LogisticInformationINData> logisticInfo;
        public List<PaymentsINData> payments;
        public ERPInfo erpInfo;

        public String approvaldate;
        public String occurrenceDate;
        public String cancellationReason;
        public String cancellationRequestedBy;
        public String cancellationDate;
        public String carrierName;
        public String trackingNumber;
        public String trackingUrl;
        public String invoiceNumber;
        public String invoiceSerialNumber;
        public String emissionDate;
        public String eletronicKey;
        public List<InvoiceINData> invoice;

        public String paymentGroups;

        public String integrationType;

        public List<OrderItemINData> items;

        public Order serialize(Map<String, Id> lookups) {
            Order ord = new Order();

            if (this.integrationType == 'StatusIN') {

                ord.status               = this.status;
                ord.internalOrderId__c   = this.internalOrderId;
                ord.RazaoCancelamento__c = this.cancellationReason;
                ord.CanceladoPor__c      = this.cancellationRequestedBy;

                ord.DataCancelamento__c  = cancellationDate != null ? (DateTime) JSON.deserialize('"' + this.cancellationDate + '"',datetime.class) : null; 
                ord.Data_Aprovacao__c    = approvaldate     != null ? (DateTime) JSON.deserialize('"' + this.approvaldate     + '"',datetime.class) : null;
                ord.DataOcorrencia__c    = occurrenceDate   != null ? (DateTime) JSON.deserialize('"' + this.occurrenceDate   + '"',datetime.class) : null;
                ord.DataEmissao__c       = emissionDate     != null ? (DateTime) JSON.deserialize('"' + this.emissionDate     + '"',datetime.class) : null;

                ord.NumeroFatura__c      = this.invoiceNumber;
                ord.NumeroSerieFatura__c = this.invoiceSerialNumber;
                ord.ChaveEletronica__c   = this.eletronicKey;
                ord.RazaoCancelamento__c = this.cancellationReason;
                ord.NomeEntregadora__c   = this.carrierName;
                ord.NumeroRastreio__c    = this.trackingNumber;
                ord.URLRastreio__c       = this.trackingUrl;
             
            } else {
                //obrigatórios
                ord.accountId = lookups.get('Account' + this.customer?.document);
                ord.effectiveDate = Date.valueOf(this.creationDate);
                ord.status = this.status;
                ord.pricebook2Id = lookups.get('StandardPb');

                ord.originOrderId__c = this.originOrderId;
                ord.internalOrderId__c = this.internalOrderId;

                System.debug('this.creationDate => ' + this.creationDate);
                ord.creationDate__c = (DateTime) JSON.deserialize('"' + this.creationDate + '"', datetime.class); //Date.valueOf(this.creationDate);
                ord.tax__c          = this.totals?.tax == null? 0 : this.totals.tax;
                ord.discounts__c    = this.totals?.discounts == null? 0 : this.totals?.discounts;
                ord.shipping__c     = this.totals?.shipping == null? 0 : this.totals?.shipping;

                ord.canalVenda__c = this.origin;
                ord.numeroPedidoCliente__c = this.externalOrderId;
                ord.numeroPedidoERP__c     = this.erpInfo?.externalOrderId;
                ord.type = this.orderType;
                ord.affiliateId__c = this.affiliateId;

                ord.endereco__c = lookups.get('Address' + this.deliveryAddress?.externalId);

                ord.CentrodeDistribuicao__c = this.sellerCode == null? lookups.get('StandardCD') : lookups.get('CD' + this.sellerCode);
                ord.brand__c = lookups.get('Brand' + this.storeCode);
                ord.IntegrationOrder__c = true;

                ord.grupo__c = this.paymentGroups;
            }

            System.debug('ord => ' + JSON.serializePretty(ord));

            return ord;
        }

        public OrderINData() {}

        public OrderINData (Order sendOrder) {
            
            this.status                   = sendOrder.status;
            this.internalOrderId          = sendOrder.internalOrderId__c;
            this.cancellationReason       = sendOrder.RazaoCancelamento__c;
            this.cancellationRequestedBy  = sendOrder.CanceladoPor__c;
            this.cancellationDate         = String.valueOf(sendOrder.DataCancelamento__c);
            this.approvalDate             = String.valueOf(sendOrder.Data_Aprovacao__c);
            this.occurrenceDate           = String.valueOf(sendOrder.DataOcorrencia__c);
            this.emissionDate             = String.valueOf(sendOrder.DataEmissao__c);
            this.invoiceNumber            = sendOrder.NumeroFatura__c;
            this.invoiceSerialNumber      = sendOrder.NumeroSerieFatura__c;
            this.eletronicKey             = sendOrder.ChaveEletronica__c;
            this.carrierName              = sendOrder.NomeEntregadora__c;
            this.trackingNumber           = sendOrder.NumeroRastreio__c;
            this.trackingUrl              = sendOrder.URLRastreio__c;
            this.creationDate             = String.valueOf(sendOrder.effectiveDate);
            this.originOrderId            = sendOrder.originOrderId__c;
            this.internalOrderId          = sendOrder.internalOrderId__c;

            this.totals                   = new TotalsINData();
            this.totals.tax               = sendOrder.tax__c;
            this.totals.discounts         = sendOrder.discounts__c;
            this.totals.shipping          = sendOrder.shipping__c;

            this.origin                   = sendOrder.canalVenda__c; 
            this.externalOrderId          = sendOrder.numeroPedidoCliente__c;

            this.erpInfo                  = new ERPInfo();
            this.erpInfo.externalOrderId  = sendOrder.numeroPedidoERP__c;
            this.orderType                = sendOrder.type;
            this.affiliateId              = sendOrder.affiliateId__c;

        } 
        
        public List<String> getRequiredFields() {
            return new List<String>{
            };
        }

        public String getFieldKey() {
            return 'internalOrderId__c';
        }
        
        public String getFieldId() {
            return 'Id';
        }
    }

    global class ERPInfo {
		public String warehouseId;
		public String externalOrderId;
		public String name;
		public String orderId;
		public String status;
    }

    global class OrderItemINData implements FieldData {
        public String sku;
        public String name;
        public Integer quantity;
        public Double listPrice;
        public Double price;
        public Double sellingPrice;
        public String preSaleDate;
        public Boolean isGift;
        public Boolean isSubsidized;
        public String imageUrl;
        public String detailUrl;
        public String originSkuId;
        public Integer index;

        public String orderId;
        public String product2Id;
        public Boolean sfOrderItem;
        // public List<PromotionINData> promotions;
        // public List<ComponentINData> promotions;
        // public List<CustomizationINData> promotions;

        public String integrationType;


        public OrderItem serialize(Map<String, Id> lookups) {
            OrderItem orderItem = new OrderItem();

            //obrigatórios
            orderItem.orderId = lookups.get('OrderItem' + this.orderId);
            orderItem.externalId__c = this.orderId + this.sku;
            
            if (this.integrationType == 'StatusIN') {

                orderItem.sku__c          = this.sku;
                orderItem.quantity        = this.quantity;
                orderItem.unitPrice       = this.price;
                orderItem.isSubsidized__c = this.isSubsidized;

                if(!this.sfOrderItem) {
                    // orderItem.listPrice = this.listPrice;
                    orderItem.pricebookEntryId = lookups.get('StandardPbEntry' + this.sku);
                    orderItem.product2Id = lookups.get('Product2' + this.sku);
                }
                
            } else {

                if(!this.sfOrderItem) {
                    // orderItem.listPrice = this.listPrice;
                    orderItem.pricebookEntryId = lookups.get('StandardPbEntry' + this.sku);
                    orderItem.product2Id = lookups.get('Product2' + this.sku);
                }
                
                orderItem.sku__c          = this.sku;
                orderItem.description     = this.name;
                orderItem.quantity        = this.quantity;
                orderItem.preco__c        = this.price;
                orderItem.unitPrice       = this.sellingPrice;
                orderItem.isGift__c       = this.isGift;
                orderItem.detailUrl__c    = this.detailUrl;
                orderItem.imageUrl__c     = this.imageUrl;
                orderItem.originSkuId__c  = this.originSkuId;
                orderItem.isSubsidized__c = this.isSubsidized;
                orderItem.PreSaleDate__c  = this.preSaleDate == null? null : Date.valueOf(this.preSaleDate);
            }
            return orderItem;
        }

        public OrderItemINData() {}

        public OrderItemINData (OrderItem sendOrderItem) {
            this.sku          = sendOrderItem.Sku__c;
            this.name         = sendOrderItem.Description;
            this.quantity     = Integer.valueOf(sendOrderItem.Quantity);
            this.listPrice    = sendOrderItem.ListPrice;
            this.price        = sendOrderItem.Preco__c;
            this.sellingPrice = sendOrderItem.UnitPrice;
            this.preSaleDate  = String.valueOf(sendOrderItem.PreSaleDate__c);
            this.isGift       = sendOrderItem.IsGift__c;
            this.isSubsidized = sendOrderItem.IsSubsidized__c;
            this.imageUrl     = sendOrderItem.ImageUrl__c;
            this.detailUrl    = sendOrderItem.DetailUrl__c;
            this.originSkuId  = sendOrderItem.OriginSkuId__c;
        }


        public List<String> getRequiredFields() {
            return new List<String>{
            };
        }

        public String getFieldKey() {
            return 'ExternalId__c';
        }

        public String getFieldId() {
            return 'Id';
        }
    }

    // Order Inner Objects Classes
    global class TotalsINData {
        public Double items;
        public Double discounts;
        public Double shipping;
        public Double tax;
    }

    global class AccountINData implements FieldData {
        public String email;
        public Boolean isCorporate;
        public String firstName;
        public String lastName;
        public String document;
        public String documentType;
        public String stateInscription;
        public List<PhoneINData> phones;

        public Account serialize(Map<String, Id> lookups) {
            Account acc = new Account();

            String onlyDigitsDocument = this.document.replaceAll('[^0-9]+', '');

            acc.externalId__c  = onlyDigitsDocument;
            acc.name           = this.firstName + ' ' + this.lastName;
            acc.FirstName__c   = this.firstName;
            acc.LastName__c    = this.lastName;
            // acc.phone          = this.phones[0]?.phone; Dev
            acc.email__c       = this.email;
            
            acc.isCorporate__c = this.isCorporate;
            // acc.phoneType__c   = this.phones[0]?.type; Dev

            if(this.documentType == 'cnpj')
                acc.cnpj__c = onlyDigitsDocument;
            else 
                acc.cpf__c  = onlyDigitsDocument;

            acc.IntegrationAccount__c = true;
            System.debug('acc ' + acc);
            return acc;
        }

        public AccountINData() {}

        public AccountINData (Account sendAccount) {

            this.document        = sendAccount.ExternalId__c;
            this.email           = sendAccount.Email__c;
            this.firstName       = sendAccount.Name;

            if (sendAccount.CPF__c != null) {
                this.documentType = sendAccount.CPF__c;
            } else {
                this.documentType = sendAccount.CNPJ__c;
            }
            
        }

        public List<String> getRequiredFields() {
            return new List<String>{
                'ExternalId__c'
            };
        }

        public String getFieldKey() {
            return 'ExternalID__c';
        }

        public String getFieldId() {
            return 'Id';
        }
    }
        
    global class AddressINData implements FieldData {
        public String addressType;
        public String receiverName;
        public String postalCode;
        public String city;
        public String state;
        public String country;
        public String street;
        public String addressNumber;
        public String neighborhood;
        public String complement;
        public String reference;

        public String externalId;
        public String accountExternalId;

        public Address__c serialize(Map<String, Id> lookups) {
            Address__c address = new Address__c();

            address.externalId__c = this.externalId;

            address.account__c = lookups.get('Account' + accountExternalId);

            address.receiverName__c = this.receiverName;

            address.city__c         = this.city;
            address.state__c        = this.state;
            address.country__c      = this.country;
            address.postalCode__c   = this.postalCode;
            address.street__c       = this.street;
            address.number__c       = this.addressNumber;
            address.neighborhood__c = this.neighborhood;
            address.complement__c   = this.complement;
            address.reference__c    = this.reference;

            return address;
        }

        public AddressINData() {}

        public AddressINData (Address__c sendAddress) {
            this.addressType   = sendAddress.AddressType__c;
            this.receiverName  = sendAddress.ReceiverName__c;
            this.postalCode    = sendAddress.PostalCode__c;
            this.city          = sendAddress.City__c;
            this.state         = sendAddress.State__c;
            this.street        = sendAddress.Street__c;
            this.country       = sendAddress.Country__c;
            this.addressNumber = sendAddress.Number__c;
            this.neighborhood  = sendAddress.Neighborhood__c;
            this.complement    = sendAddress.Complement__c;
            this.reference     = sendAddress.Reference__c;
        }

        public List<String> getRequiredFields() {
            return new List<String>{
                'postalCode__c', 
                'number__c'
            };
        }

        public String getFieldKey() {
            return 'ExternalId__c';
        }

        public String getFieldId() {
            return 'Id';
        }
    }

    global class LogisticInformationINData implements FieldData {
        public PickupStoreInfoINData pickupStoreInfo;
        public Integer itemIndex;
        public String logisticContract;
        public Double price;
        public Double listPrice;
        public Double sellingPrice;
        public String deliveryCompany;
        public String shippingEstimate;
        public String shippingEstimateDate;
        public String deliveryChannel;

        public String orderId;

        public LogisticInformation__c serialize(Map<String, Id> lookups) {
            LogisticInformation__c logisticInfo = new LogisticInformation__c();

            logisticInfo.ExternalId__c = this.orderId + this.deliveryCompany + this.itemIndex;

            logisticInfo.pedido__c         = lookups.get('OrderItem' + this.orderId);
            logisticInfo.additionalInfo__c = this.pickupStoreInfo?.additionalInfo;
            logisticInfo.address__c        = this.pickupStoreInfo?.address;
            logisticInfo.dockId__c         = this.pickupStoreInfo?.dockId == null? 0 : Decimal.valueOf(this.pickupStoreInfo?.dockId);
            logisticInfo.friendlyName__c   = this.pickupStoreInfo?.friendlyName;
            logisticInfo.isPickupStore__c  = this.pickupStoreInfo?.isPickupStore;

            logisticInfo.logisticContract__c     = this.logisticContract;
            logisticInfo.price__c                = this.price;
            logisticInfo.listPrice__c            = this.listPrice;
            logisticInfo.sellingPrice__c         = this.sellingPrice;
            logisticInfo.deliveryCompany__c      = this.deliveryCompany;
            logisticInfo.deliveryChannel__c      = this.deliveryChannel;
            logisticInfo.shippingEstimate__c     = this.shippingEstimate;
            logisticInfo.shippingEstimate__c     = this.shippingEstimate;
            logisticInfo.shippingEstimateDate__c = (DateTime) JSON.deserialize('"' + this.shippingEstimateDate + '"', DateTime.class);
            // logisticInfo.shippingEstimateDate__c = Datetime.parse(this.shippingEstimateDate);
            logisticInfo.deliveryChannel__c      = this.deliveryChannel;

            return logisticInfo;   
        }

        public LogisticInformationINData() {}

        public LogisticInformationINData (LogisticInformation__c logisticInformation) {

            this.deliveryChannel                     = logisticInformation.deliveryChannel__c;
            this.deliveryCompany                     = logisticInformation.deliveryCompany__c;
            this.listPrice                           = logisticInformation.listPrice__c;
            this.orderId                             = logisticInformation.Pedido__c;

            this.pickupStoreInfo                     = new PickupStoreInfoINData();
            this.pickupStoreInfo.additionalInfo      = logisticInformation.additionalInfo__c;
            this.pickupStoreInfo.address             = logisticInformation.address__c;
            this.pickupStoreInfo.dockId              = String.valueOf(logisticInformation.dockId__c);
            this.pickupStoreInfo.friendlyName        = logisticInformation.friendlyName__c;
            this.pickupStoreInfo.isPickupStore       = logisticInformation.isPickupStore__c;
            this.price                               = logisticInformation.price__c;
            this.sellingPrice                        = logisticInformation.sellingPrice__c;
            this.shippingEstimate                    = logisticInformation.shippingEstimate__c;
            this.shippingEstimateDate                = String.valueOf(logisticInformation.shippingEstimateDate__c);

        }

        public List<String> getRequiredFields() {
            return new List<String>{
            };
        }

        public String getFieldKey() {
            return 'ExternalId__c';
        }

        public String getFieldId() {
            return 'Id';
        }
    }

    global class PaymentsINData implements FieldData {
        public String paymentId;
        public String originPaymentId;
        public Double value;
        public Integer interestAmount;
        public Integer interestRate;
        public String paymentGroup;
        public String dueDate;
        public Integer installments;
        public String tid;
        public String nsu;
        public String authId;
        public String redemptionCode;
        public String url;
        public String cardBrand;
        public String firstDigits;
        public String lastDigits;
        public String cardHoldersName;

        public String orderId;

        public Payments__c serialize(Map<String, Id> lookups) {

            Payments__c payment = new Payments__c();

            // externalId
            payment.originPaymentId__c = this.orderId + (this.originPaymentId == null? this.paymentId : this.originPaymentId);
            payment.pedido__c          = lookups.get('OrderItem' + this.orderId);

            payment.value__c           = this.value;
            payment.interestAmount__c  = this.interestAmount;
            payment.interestRate__c    = this.interestRate;
            payment.grupo__c           = this.paymentGroup;
            payment.dueDate__c         = this.dueDate == null? null : Date.valueOf(this.dueDate);
            payment.installments__c    = this.installments;
            payment.redemptionCode__c  = this.redemptionCode;
            payment.cardBrand__c       = this.cardBrand;
            payment.cardHoldersName__c = this.cardHoldersName;

            payment.tid__c             = this.tid;
            payment.authId__c          = this.authId;
            payment.firstDigits__c     = this.firstDigits;
            payment.lastDigits__c      = this.lastDigits;

            // inexistentes
            // payment.nsu__c             = this.nsu;
            // payment.url__c             = this.url;
            
            return payment;
        }

        public PaymentsINData() {}

        public PaymentsINData (Payments__c sendPayments) {
            this.authId          = sendPayments.authId__c;
            this.cardBrand       = sendPayments.cardBrand__c;
            this.cardHoldersName = sendPayments.cardHoldersName__c;
            this.dueDate         = String.valueOf(sendPayments.dueDate__c);
            this.firstDigits     = sendPayments.firstDigits__c;
            this.installments    = Integer.valueOf(sendPayments.installments__c);
            this.interestAmount  = Integer.valueOf(sendPayments.interestAmount__c);
            this.interestRate    = Integer.valueOf(sendPayments.interestRate__c);
            this.lastDigits      = sendPayments.lastDigits__c;
            this.orderId         = sendPayments.Pedido__c;
            this.originPaymentId = sendPayments.originPaymentId__c;
            this.paymentGroup    = sendPayments.Grupo__c;
            this.redemptionCode  = sendPayments.redemptionCode__c;
            this.tid             = sendPayments.tid__c;
            this.value           = sendPayments.value__c;
            
        }

        public List<String> getRequiredFields() {
            return new List<String>{
            };
        }

        public String getFieldKey() {
            return 'originPaymentId__c';
        }

        public String getFieldId() {
            return 'Id';
        }
    }

    // Customer Inner Object Classes
    global class PhoneINData {
        public String phone;
        public String type;

        public PhoneINData(){}
    }

    // Pickup Store Inner Object Classes
    global class PickupStoreInfoINData {
        public String additionalInfo;
        public String address;
        public String dockId;
        public String friendlyName;
        public Boolean isPickupStore;
    }
        
    // OrderItem Inner Objects Classes
    // global class PromotionINData implements FieldData {}
    // global class ComponentINData implements FieldData {}
    // global class CustomizationINData implements FieldData {}

    // Response structure
    global virtual class Response {
        public String  idSalesforce;
        public String  externalCode;
        public String  errorMessage;
        public Boolean status;
        public String  sObjectType;
        
        public void success(String idSalesforce, String externalCode, String sObjectType){
            this.idSalesforce = idSalesforce;
            this.externalCode = externalCode;
            this.status       = true;
            this.SObjectType  = sObjectType;
        }
        
        public void error(String externalCode, String errorMessage, String sObjectType){
            this.externalCode = externalCode;
            this.status       = false;
            this.errorMessage = errorMessage;
            this.SObjectType  = sObjectType;
        }

        public void error(String idSalesforce, String externalCode, String errorMessage, String sObjectType){
            this.idSalesforce = idSalesforce;
            this.externalCode = externalCode;
            this.status       = false;
            this.errorMessage = errorMessage;
            this.SObjectType  = sObjectType;
        }
    }
        
    // Response structure for integration of parent and child objects
    global class ResponseParent extends Response {
        public List<TemplateDataIntegrationFields.Response> items;
    }
}