public with sharing class IntegrationReclameAqui {

    private static final String ENDPOINT_RETRIEVE_ALL_TICKETS       = 'https://app.hugme.com.br/api/ticket/v1/tickets';
    private static final String ENDPOINT_SEND_PUBLIC_MESSAGE        = 'https://app.hugme.com.br/api/ticket/v1/tickets/message/public';
    private static final String ENDPOINT_SEND_PRIVATE_MESSAGE       = 'https://app.hugme.com.br/api/ticket/v1/tickets/message/private';
    private static final String ENDPOINT_REQUEST_TICKET_EVALUATION  = 'https://app.hugme.com.br/api/ticket/v1/tickets/evaluation';
    private static final String ENDPOINT_REQUEST_TICKET_MODERATION  = 'https://app.hugme.com.br/api/ticket/v1/tickets/moderation';
    
    //Retrieve All Tickets Funcionando OK!
    public static TemplateDataIntegrationFields.ReclameAquiRetriveAllTicketINData retrieveAllTickets() {
        String accessToken = ClientReclameAqui.getAccessToken();

        Http conex       = new Http();
        HttpRequest resq = new HttpRequest();

        resq.setEndpoint(ENDPOINT_RETRIEVE_ALL_TICKETS);
        resq.setMethod('GET');
        resq.setHeader('Content-Type', 'application/json');
        resq.setHeader('Authorization', 'Bearer ' + accessToken);

        HttpResponse response = conex.send(resq);
        System.debug('STATUS CODE Retrieve All Tickets ' + response.getStatusCode());
        System.debug('BODY Retrieve All Tickets ' + JSON.serializePretty(response.getBody()));
        TemplateDataIntegrationFields.ReclameAquiRetriveAllTicketINData deserializeResults = new TemplateDataIntegrationFields.ReclameAquiRetriveAllTicketINData();
        if(response != null && response.getStatusCode() == 200){
            Type resultType = Type.forName('TemplateDataIntegrationFields.ReclameAquiRetriveAllTicketINData');
            deserializeResults = (TemplateDataIntegrationFields.ReclameAquiRetriveAllTicketINData)JSON.deserialize(response.getBody(), resultType);
            //System.debug('===========> deserialize() results = ' + JSON.serializePretty(deserializeResults)); 
        } 
        return deserializeResults;
    }
    
    //Send Public Message Funcionando OK!
    @AuraEnabled(cacheable=true)
    public static String sendPublicMessage(String id, String message) {

        String retorno = '';

        System.debug('ID '      + id);
        System.debug('Message ' + message);
        IntegrationReclameAqui.SendPublicMessageModel modal = new IntegrationReclameAqui.SendPublicMessageModel(id, message);
        String accessToken = ClientReclameAqui.getAccessToken();

        Http conexMessage       = new Http();
        HttpRequest resqMessage = new HttpRequest();

        Map<String, String> body = new Map<String, String>{
            'id' => modal.id,
            'message' => modal.message
        };

        resqMessage.setEndpoint(ENDPOINT_SEND_PUBLIC_MESSAGE);
        resqMessage.setMethod('POST');
        resqMessage.setHeader('Content-Type', 'application/json');
        resqMessage.setHeader('Authorization', 'Bearer ' + accessToken);
        resqMessage.setBody(JSON.serialize(body));

        HttpResponse responseMessage = conexMessage.send(resqMessage);
        System.debug('STATUS CODE Send Public Message ' + responseMessage.getStatusCode());
        System.debug('BODY ' + responseMessage.getBody());
        if (responseMessage.getStatusCode() == 200) {
            retorno = 'Mensagem enviada com sucesso!';
        } else {
            retorno = 'A Mensagem encontra error ao ser enviada.';
        }
        return retorno;
    }

    //Private Error 400
    public static void sendPrivateMessage(IntegrationReclameAqui.SendPrivateMessageModel model){
        String accessToken = ClientReclameAqui.getAccessToken();

        Http conexPrivateMessage       = new Http();
        HttpRequest resqPrivateMessage = new HttpRequest();

        // Map<String,String> body = new Map<String,String>{
        //     'id'      => model.id,
        //     'message' => model.message,
        //     'email'   => model.email,
        //     'file'    => model.file
        // };

        String body = '';
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('id', EncodingUtil.urlEncode(model.id, 'UTF-8'));
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('message', EncodingUtil.urlEncode(model.message, 'UTF-8'));
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('email', EncodingUtil.urlEncode(model.email, 'UTF-8'));
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('file', EncodingUtil.urlEncode(model.file, 'UTF-8'));
        body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        Blob formBlob = EncodingUtil.base64Decode(body);
        String contentLength = string.valueOf(formBlob.size());
    
        resqPrivateMessage.setEndpoint(ENDPOINT_SEND_PRIVATE_MESSAGE);
        resqPrivateMessage.setMethod('POST');
        resqPrivateMessage.setHeader('Connection', 'keep-alive');
        resqPrivateMessage.setHeader('Content-Length', contentLength);
        resqPrivateMessage.setHeader('Content-Type', HttpFormBuilder.GetContentType());
        resqPrivateMessage.setHeader('Authorization', 'Bearer ' + accessToken);
        resqPrivateMessage.setBodyAsBlob(formBlob);

        HttpResponse responsePrivateMessage = conexPrivateMessage.send(resqPrivateMessage);
        System.debug('STATUS CODE Send Private Message ' + responsePrivateMessage.getStatusCode());
        System.debug('BODY ' + responsePrivateMessage.getBody());
    }

    //Evaluation Funcionando OK!
    public static void requestTicketEvaluation(IntegrationReclameAqui.RequestTicketEvaluationModel model){
        String accessToken = ClientReclameAqui.getAccessToken();

        Http conexEvaluation        = new Http();
        HttpRequest resqEvaluation  = new HttpRequest();

        Map<String,String> body = new Map<String,String>{
            'id' => model.id
        };

        resqEvaluation.setEndpoint(ENDPOINT_REQUEST_TICKET_EVALUATION);
        resqEvaluation.setMethod('POST');
        resqEvaluation.setHeader('Content-Type', 'application/json');
        resqEvaluation.setHeader('Authorization', 'Bearer ' + accessToken);
        resqEvaluation.setBody(JSON.serialize(body));

        HttpResponse responseEvaluation = conexEvaluation.send(resqEvaluation);
        System.debug('STATUS CODE Request Ticket Evaluation ' + responseEvaluation.getStatusCode());
        System.debug('BODY ' + responseEvaluation.getBody());
    }

    //Moderation Error 400 
    public static void requestTicketModeration(IntegrationReclameAqui.RequestTicketModerationModel model){
        String accessToken = ClientReclameAqui.getAccessToken();

        Http conexModeration       = new Http();
        HttpRequest resqModeration = new HttpRequest();

        Map<String,String> body = new Map<String,String>{
            'id'      => model.id,
            'message' => model.message,
            'reason'  => model.reason,
            'file'    => model.file
        };

        resqModeration.setEndpoint(ENDPOINT_REQUEST_TICKET_MODERATION);
        resqModeration.setMethod('POST');
        resqModeration.setHeader('Content-Type', HttpFormBuilder.GetContentType());
        resqModeration.setHeader('Authorization', 'Bearer ' + accessToken);
        resqModeration.setBody(JSON.serialize(body));

        HttpResponse responseModeration = conexModeration.send(resqModeration);
        System.debug('STATUS CODE Request Ticket Moderarion ' + responseModeration.getStatusCode());
        System.debug('BODY ' + responseModeration.getBody());
    }
    public class SendPublicMessageModel {
        public String id;
        public String message;

        public SendPublicMessageModel(String id, String message) {
            this.id      = id;
            this.message = message;
        }
    }

    public class SendPrivateMessageModel {
        public String id;
        public String message;
        public String email;
        public String file;  

        public SendPrivateMessageModel(String id, String message, String email, String file) {
            this.id      = id;
            this.message = message;
            this.email   = email;
            this.file    = file;
        }
    }

    public class RequestTicketEvaluationModel {
        public String id;

        public RequestTicketEvaluationModel(String id) {
            this.id = id;
        }
    }

    public class RequestTicketModerationModel {
        public String id;
        public String message;
        public String reason;
        public String file;

        public RequestTicketModerationModel(String id, String message, String reason, String file) {
            this.id      = id;
            this.message = message;
            this.reason  = reason;
            this.file    = file;
        }
    }

    //Método de TESTE****** NÃO APAGUE POR ENQUANTO**********
    public static void uploadFile(Blob file_body, String file_name, String reqEndPoint, IntegrationReclameAqui.SendPrivateMessageModel model){
        // Repost of code  with fix for file corruption issue
        // Orignal code postings and explanations
        // http://enreeco.blogspot.in/2013/01/salesforce-apex-post-mutipartform-data.html
        // http://salesforce.stackexchange.com/questions/24108/post-multipart-without-base64-encoding-the-body
        // Additional changes commented GW: that fix issue with occasional corruption of files
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'nContent-Disposition: form-data; name="file"; filename="'+file_name+'";nContent-Type: application/octet-stream';
        // GW: Do not prepend footer with rn, you'll see why in a moment
        // String footer = 'rn--'+boundary+'--'; 
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'rnrn'));
        while(headerEncoded.endsWith('='))
        {
         header+=' ';
         headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'rnrn'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        // GW: Do not encode footer yet
        // String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
   
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
   
        // GW: Replacing this entire section
        /*
        if(last4Bytes.endsWith('='))
        {
             Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
             HttpRequest tmp = new HttpRequest();
             tmp.setBodyAsBlob(decoded4Bytes);
             String last4BytesFooter = tmp.getBody()+footer;   
             bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded.substring(0,bodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
        }
        else
        {
              bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        */
       // GW: replacement section to get rid of padding without corrupting data
       if(last4Bytes.endsWith('==')) {
          // The '==' sequence indicates that the last group contained only one 8 bit byte
          // 8 digit binary representation of CR is 00001101
          // 8 digit binary representation of LF is 00001010
          // Stitch them together and then from the right split them into 6 bit chunks
          // 0000110100001010 becomes 0000 110100 001010
          // Note the first 4 bits 0000 are identical to the padding used to encode the
          // second original 6 bit chunk, this is handy it means we can hard code the response in
          // The decimal values of 110100 001010 are 52 10
          // The base64 mapping values of 52 10 are 0 K
          // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
          // Therefore, we replace == with 0K
          // Note: if using nn instead of rn replace == with 'oK'
          last4Bytes = last4Bytes.substring(0,2) + '0K';
          bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
          // We have appended the rn to the Blob, so leave footer as it is.
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
          // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
          // We replace final 8 bit byte with a CR e.g. r
          // 8 digit binary representation of CR is 00001101
          // Ignore the first 2 bits of 00 001101 they have already been used up as padding
          // for the existing data.
          // The Decimal value of 001101 is 13
          // The base64 value of 13 is N
          // Therefore, we replace = with N
          // Note: if using n instead of r replace = with 'K'
          last4Bytes = last4Bytes.substring(0,3) + 'N';
          bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
          // We have appended the CR e.g. r, still need to prepend the line feed to the footer
          footer = 'n' + footer;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
          // Prepend the CR LF to the footer
          footer = 'rn' + footer;
          String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
          bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
   
        HttpRequest req = new HttpRequest();

        // String body = '';
        // body += HttpFormBuilder.WriteBoundary();
        // body += HttpFormBuilder.WriteBodyParameter('id', EncodingUtil.urlEncode(model.id, 'UTF-8'));
        // body += HttpFormBuilder.WriteBoundary();
        // body += HttpFormBuilder.WriteBodyParameter('message', EncodingUtil.urlEncode(model.message, 'UTF-8'));
        // body += HttpFormBuilder.WriteBoundary();
        // body += HttpFormBuilder.WriteBodyParameter('email', EncodingUtil.urlEncode(model.email, 'UTF-8'));
        // body += HttpFormBuilder.WriteBoundary();
        // body += HttpFormBuilder.WriteBodyParameter('file', EncodingUtil.base64Encode(bodyBlob));
        // body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        // Blob formBlob = EncodingUtil.base64Decode(body);
        Map<String,String> body = new Map<String,String>{
            'id'      => model.id,
            'message' => model.message,
            'email'   => model.email,
            'file'    => model.file
        };
        //String contentLength = string.valueOf(formBlob.size());
    
        // resqPrivateMessage.setEndpoint(ENDPOINT_SEND_PRIVATE_MESSAGE);
        // resqPrivateMessage.setMethod('POST');
        // resqPrivateMessage.setHeader('Connection', 'keep-alive');
        // resqPrivateMessage.setHeader('Content-Length', contentLength);
        // resqPrivateMessage.setHeader('Content-Type', 'multipart/form-data');
        // resqPrivateMessage.setHeader('Authorization', 'Bearer ' + accessToken);
        // resqPrivateMessage.setBodyAsBlob(formBlob);
        String accessToken = ClientReclameAqui.getAccessToken();

        req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
        req.setMethod('POST');
        req.setHeader('Connection', 'keep-alive');
        //req.setHeader('Content-Length', contentLength);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setEndpoint(reqEndPoint);
        req.setBody(JSON.serialize(body));
        req.setTimeout(120000);
        System.debug('REQUEST ' + req);
        System.debug('BODY -> ' + body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('STATUS CODE PRIVATE ' + res.getStatusCode());
        System.debug('BODY ' + res.getBody());
    }   
}