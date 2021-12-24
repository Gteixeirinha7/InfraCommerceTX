@IsTest
public class SroXML2Test {
    
    static testMethod void test() {
        SroXML2.Evento event = new SroXML2.Evento();
        event.tipo           = 'tipo';
        event.status         = 'status';
        event.data           = 'data';
        event.hora           = 'hora';
        event.descricao      = 'descricao';
        event.detalhe        = 'detalhe';
        event.recebedor      = 'recebedor';
        event.documento      = 'documento';
        event.comentario     = 'comentario';
        event.local          = 'local';
        event.codigo         = 'codigo';
        event.cidade         = 'cidade';
        event.uf             = 'uf';
        event.sto            = 'sto';
        event.amazoncode     = 'amazoncode';
        event.amazontimezone = 'amazontimezone';
        
        SroXML2.ObjetoRastreio objRastreio = new SroXML2.ObjetoRastreio();
        objRastreio.numero    = 'numero';
        objRastreio.sigla     = 'sigla';
        objRastreio.nome      = 'nome';
        objRastreio.categoria = 'categoria';
        objRastreio.erro      = 'erro';
        objRastreio.evento    = new List<SroXML2.Evento>{event};

        SroXML2 xml2 = new SroXML2();
        xml2.versao        = '2.0';
        xml2.qtd           = '1';
        xml2.TipoPesquisa  = 'TipoPesquisa';
        xml2.TipoResultado = 'TipoResultado';
        xml2.objeto        = new List<SroXML2.ObjetoRastreio>{objRastreio};
    }
}