## 1. Modelagem e Arquitetura

### 1.1 Por que usar um SGBD Relacional?
Para esse cenário, um SGBD relacional é a melhor escolha porque o sistema acadêmico trabalha com muitos dados que se relacionam entre si, como alunos, disciplinas, docentes, turmas e matrículas. Nesse tipo de situação, é muito importante garantir que os dados estejam organizados e corretos.

Além disso, o banco relacional oferece suporte às propriedades ACID, que ajudam a manter a segurança e a consistência dos dados:
- **Atomicidade:** uma operação acontece por completo ou não acontece.
- **Consistência:** os dados continuam válidos depois de cada operação.
- **Isolamento:** uma transação não atrapalha a outra.
- **Durabilidade:** depois de salvar, o dado continua registrado mesmo se houver falha.

NoSQL é muito útil em outros contextos, principalmente quando se precisa de mais flexibilidade ou escalabilidade, mas para esse caso o mais importante é a integridade dos dados e o controle dos relacionamentos. Por isso, o modelo relacional faz mais sentido.

### 1.2 Por que usar schemas em vez de deixar tudo em `public`?
Em um ambiente profissional, usar schemas ajuda a organizar melhor o banco. Em vez de deixar tudo misturado no `public`, podemos separar as tabelas por assunto ou responsabilidade.

Neste projeto, por exemplo:
- o schema `academico` guarda as tabelas do sistema acadêmico;
- o schema `seguranca` guarda os dados ligados aos usuários.

Isso deixa o banco mais organizado, facilita a manutenção, melhora a leitura dos scripts e também ajuda na parte de permissões e segurança.

---

## 2. Projeto e Normalização

### 2.1 Análise da planilha legada
A planilha legada mistura várias informações em uma estrutura só, como dados do aluno, e-mail, endereço, disciplina, docente, operador pedagógico, ciclo e nota final. Isso causa repetição de dados e aumenta a chance de erro ou inconsistência.

Por exemplo, o nome do aluno e o e-mail aparecem várias vezes, uma vez para cada disciplina cursada. O mesmo acontece com o nome do docente e com os dados da disciplina.

### 2.2 Aplicação da 1FN
A Primeira Forma Normal pede que cada campo tenha apenas um valor e que não existam grupos repetidos dentro de uma mesma linha.

Na planilha, cada linha já representa uma ocorrência separada, o que ajuda. Mesmo assim, ainda existe muita repetição de informações. Por isso, os dados foram separados em tabelas próprias, para que cada entidade ficasse armazenada uma vez só.

### 2.3 Aplicação da 2FN
A Segunda Forma Normal pede que os atributos dependam totalmente da chave da tabela.

Na planilha original, vários campos não dependem da ocorrência completa da matrícula em disciplina, e sim de outras entidades. Por exemplo:
- nome, e-mail e endereço dependem do usuário;
- nome da disciplina e carga horária dependem da disciplina;
- nome do docente depende do docente.

Por isso, essas informações foram separadas em tabelas específicas.

### 2.4 Aplicação da 3FN
A Terceira Forma Normal pede que não existam dependências transitivas, ou seja, um atributo não-chave não deve depender de outro atributo não-chave.

Para resolver isso, os dados foram organizados assim:
- informações pessoais e de contato ficaram em `seguranca.usuario`;
- os dados acadêmicos do aluno ficaram em `academico.aluno`;
- docentes, disciplinas, operadores e turmas ficaram em tabelas próprias;
- a tabela de matrícula ficou responsável apenas pelo vínculo entre aluno e turma, junto com a nota.

Assim, o banco ficou mais organizado, sem redundância desnecessária e com melhor integridade.

### 2.5 Modelo Lógico

#### Schema `seguranca`

**usuario**
- `id_usuario` (PK)
- `nome_usuario`
- `email_usuario`
- `endereco_usuario`
- `ativo`

#### Schema `academico`

**operador_pedagogico**
- `matricula_operador_pedagogico` (PK)
- `ativo`

**aluno**
- `id_aluno` (PK)
- `ra_aluno` (UNIQUE)
- `data_ingresso`
- `id_usuario` (FK -> seguranca.usuario.id_usuario)
- `matricula_operador_pedagogico` (FK -> academico.operador_pedagogico.matricula_operador_pedagogico)
- `ativo`

**docente**
- `id_docente` (PK)
- `nome_docente` (UNIQUE)
- `ativo`

**disciplina**
- `id_disciplina` (PK)
- `cod_servico_academico` (UNIQUE)
- `nome_disciplina`
- `carga_h`
- `ativo`

**turma**
- `id_turma` (PK)
- `id_disciplina` (FK -> academico.disciplina.id_disciplina)
- `id_docente` (FK -> academico.docente.id_docente)
- `ciclo_calendario`
- `ativo`

**matricula**
- `id_matricula` (PK)
- `id_aluno` (FK -> academico.aluno.id_aluno)
- `id_turma` (FK -> academico.turma.id_turma)
- `score_final`
- `situacao`
- `ativo`

---

## 5. Transações e Concorrência

Se dois operadores da secretaria tentarem alterar a nota do mesmo aluno ao mesmo tempo, o SGBD precisa garantir que o valor final não fique errado ou corrompido.

Isso é resolvido principalmente pela propriedade de **isolamento**, que faz parte do ACID. Ela garante que uma transação não interfira de forma incorreta na outra.

Na prática, o banco pode aplicar um bloqueio no registro que está sendo alterado. Enquanto a primeira transação não terminar, a segunda pode ficar aguardando. Assim, o banco evita que duas pessoas escrevam no mesmo dado ao mesmo tempo de forma desorganizada.

Os **locks** ajudam justamente nisso: controlar o acesso concorrente ao mesmo registro. Com isso, o valor final da nota continua consistente e o sistema não perde a integridade dos dados.