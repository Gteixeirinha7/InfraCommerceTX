@isTest
private class logisticaReversaCorreiosTest {
	
	@isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new logisticareversaCorreiosCMockImpl());
		logisticaReversaCorreios parentObject = new logisticaReversaCorreios();
		new logisticaReversaCorreios.acompanharPedido();
		new logisticaReversaCorreios.acompanharPedidoResponse();
		new logisticaReversaCorreios.coletaReversa();
		new logisticaReversaCorreios.coletasSolicitadas();
		new logisticaReversaCorreios.historicoColeta();
		new logisticaReversaCorreios.objeto();
		new logisticaReversaCorreios.objetoPostal();
		new logisticaReversaCorreios.pessoa();
		new logisticaReversaCorreios.produto();
		new logisticaReversaCorreios.remetente();
		new logisticaReversaCorreios.resultadoSolicitacao();
		new logisticaReversaCorreios.retornoAcompanhamento();
		new logisticaReversaCorreios.retornoPostagem();
		new logisticaReversaCorreios.retornoSobreWebService();
		new logisticaReversaCorreios.sobreWebService();
		new logisticaReversaCorreios.sobreWebServiceResponse();
		new logisticaReversaCorreios.solicitarPostagemReversa();
		new logisticaReversaCorreios.solicitarPostagemReversaResponse();
	}
	@isTest static void coverCodeForacompanharPedido(){
		Test.setMock(WebServiceMock.class, new logisticareversaCorreiosCMockImpl());
		logisticaReversaCorreios.logisticaReversaWSPort testObject = new logisticaReversaCorreios.logisticaReversaWSPort();
		System.assertEquals(null, testObject.acompanharPedido(null, null, null, null));
	}
	@isTest static void coverCodeForsobreWebService(){
		Test.setMock(WebServiceMock.class, new logisticareversaCorreiosCMockImpl());
		logisticaReversaCorreios.logisticaReversaWSPort testObject = new logisticaReversaCorreios.logisticaReversaWSPort();
		System.assertEquals(null, testObject.sobreWebService());
	}
	@isTest static void coverCodeForsolicitarPostagemReversa(){
		Test.setMock(WebServiceMock.class, new logisticareversaCorreiosCMockImpl());
		logisticaReversaCorreios.logisticaReversaWSPort testObject = new logisticaReversaCorreios.logisticaReversaWSPort();
		System.assertEquals(null, testObject.solicitarPostagemReversa(null, null, null, null, null));
	}
}