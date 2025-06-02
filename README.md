# Salesforce Bot

Site para teste (Haverá um balão preto no canto inferior direito da tela): https://adrenaline-rds-dev-ed.develop.my.site.com/help

Usuário para entrar na org: apexadrenaline@bot.com / Senha: teste123

Para simular a transferência, é essencial que o usuário acima esteja online.

Site usado para simular integração: https://webhook.site/#!/view/c59b9c20-a505-45d8-a461-d575f0bf0cc2/6b465619-da5a-404c-b7c5-eaed0e864dc0

# Sobre o projeto

Minha arquitetura de bot foi desenvolvida para ser dinâmica e centrada no cliente. Utilizo diálogos que coletam informações e um componente reutilizável para confirmação de dados (com perguntas "Sim ou Não"), que podem ser acionados a qualquer momento no fluxo conversacional. Após interagir com qualquer menu, o cliente sempre é perguntado se deseja encerrar a conversa ou retornar ao menu principal.

Para rastrear a jornada do cliente de forma eficaz, criei um campo Journey na Messaging Session. Este campo é atualizado por um Flow do Salesforce, chamado diretamente do bot, que registra o nome da jornada atual do cliente.

Fluxos Detalhados do Bot:
- Diálogo "Pegar informações do cliente":
  Este fluxo solicita o e-mail do cliente e aciona um Flow para verificar a existência de uma conta.
  Oferece a opção de corrigir o e-mail caso o cliente o tenha digitado incorretamente.
  Se uma conta for encontrada, o bot recupera os dados associados; caso contrário, ele coleta as informações necessárias do cliente para prosseguir.

- Diálogo "Rastreamento de Pedido":
  O cliente digita o número do pedido para consulta.
  
  Números para Teste (Simulação):
  404: Gera um erro de "produto não encontrado".
  500: Gera um erro de "serviço inválido".
  401: Gera um "erro inesperado".
  Qualquer número maior que 600: Simula um cenário de sucesso.
  
  Quando o número é inserido, uma classe Apex é invocada para consultar um serviço de rastreamento. O bot então exibe a mensagem apropriada de sucesso ou erro com base na resposta do serviço.

- Diálogo "Suporte Técnico":
  Coleta as informações pertinentes do cliente.
  Chama um Flow para criar um caso de suporte técnico.
  Se necessário, o bot oferece a transferência para um agente (observação: para simular a transferência, um agente precisa estar online e disponível).
  
- Diálogo "Política de Devolução":
  Realiza uma busca na base de conhecimento (Knowledge) do próprio bot sobre políticas de devolução.
  Exibe o conteúdo da política para o cliente.
  Pergunta se o cliente deseja iniciar uma devolução e, se sim, coleta as informações necessárias para abrir um caso de devolução via Flow.
  
- Diálogo "Contratação de Serviço":
  Busca e exibe os produtos disponíveis no Price Book Bot Offers.
  Permite ao cliente selecionar o produto desejado.
  Coleta as informações do cliente e, em seguida, cria uma oportunidade vinculada a esse produto e uma tarefa associada a ela.
