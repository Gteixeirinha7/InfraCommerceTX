public with sharing class SroXML2 {

    public String versao;
    public String qtd;
    public String TipoPesquisa;
    public String TipoResultado;
    public List<ObjetoRastreio> objeto;

    public class ObjetoRastreio {
        public String numero;
        public String sigla;
        public String nome;
        public String categoria;
        public String erro;
        public List<Evento> evento;
    }

    public class Evento {
        public String tipo;
        public String status;
        public String data;
        public String hora;
        public String descricao;
        public String detalhe;
        public String recebedor;
        public String documento;
        public String comentario;
        public String local;
        public String codigo;
        public String cidade;
        public String uf;
        public String sto;
        public String amazoncode;
        public String amazontimezone;
    }
}