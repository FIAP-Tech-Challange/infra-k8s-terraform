# Authorizer Lambda Tests

Este diretório contém os testes unitários e de integração para o authorizer Lambda do gateway.

## Estrutura dos Testes

```
__tests__/
├── Exception.test.js      # Testes para classes de exceção
├── DatabaseClient.test.js # Testes para cliente do banco de dados
├── index.test.js         # Testes unitários do handler principal
└── integration.test.js   # Testes de integração completos
```

## Configuração

### Dependências

As seguintes dependências de desenvolvimento são necessárias:

- `jest`: Framework de testes
- `@jest/globals`: Globals do Jest para ES modules
- `jest-environment-node`: Ambiente Node.js para Jest
- `@babel/core` e `@babel/preset-env`: Para suporte a ES modules
- `babel-jest`: Transformador Babel para Jest

### Arquivos de Configuração

- `jest.config.js`: Configuração principal do Jest
- `jest.setup.js`: Configurações globais e setup dos testes
- `.babelrc`: Configuração do Babel para transpilação

## Executando os Testes

### Instalar dependências

```bash
npm install
```

### Executar todos os testes

```bash
npm test
```

### Executar testes em modo watch

```bash
npm run test:watch
```

### Executar testes com coverage

```bash
npm run test:coverage
```

### Executar testes específicos

```bash
# Executar apenas testes de uma classe
npm test Exception.test.js

# Executar testes que contenham determinado padrão
npm test -- --testNamePattern="should authorize"
```

## Tipos de Testes

### 1. Testes Unitários (`Exception.test.js`)

- Testa a classe `TotemInvalidOrNotFound`
- Verifica criação, mensagem e comportamento da exceção

### 2. Testes Unitários (`DatabaseClient.test.js`)

- Testa inicialização do cliente do banco
- Testa execução de queries
- Testa tratamento de erros de conexão
- Usa mocks do módulo `pg`

### 3. Testes Unitários (`index.test.js`)

- Testa o handler principal do Lambda
- Testa validação de tokens
- Testa integração com o banco de dados
- Testa diferentes cenários de autorização
- Usa mocks das dependências

### 4. Testes de Integração (`integration.test.js`)

- Testa o fluxo completo de autorização
- Testa cenários edge cases
- Simula falhas de banco de dados
- Testa comportamento com dados malformados

## Cobertura de Testes

Os testes cobrem:

- ✅ Validação de tokens (presença, tipo, formato)
- ✅ Conexão com banco de dados
- ✅ Execução de queries
- ✅ Tratamento de erros
- ✅ Retorno de respostas corretas
- ✅ Manipulação de variáveis de ambiente
- ✅ Casos extremos e edge cases

## Mocks Utilizados

- **pg module**: Mock completo do cliente PostgreSQL
- **console methods**: Mock para reduzir ruído nos testes
- **environment variables**: Configuração de variáveis de teste

## Variáveis de Ambiente para Teste

As seguintes variáveis são configuradas automaticamente nos testes:

```
DB_NAME=test_db
DB_HOST=localhost
DB_PASSWORD=test_password
DB_PORT=5432
DB_USER=test_user
```

## Estrutura dos Resultados de Teste

### Autorização Bem-sucedida

```javascript
{
  isAuthorized: true,
  context: {
    totemId: "totem-id-123"
  }
}
```

### Autorização Falhada

```javascript
{
  isAuthorized: false,
  context: {
    reason: "Totem invalid or not found" // ou "Internal server error"
  }
}
```

## Contribuindo

Ao adicionar novos testes:

1. Siga o padrão de nomenclatura existente
2. Use describe/it para organizar os testes
3. Inclua testes para casos de sucesso e falha
4. Mock todas as dependências externas
5. Limpe os mocks entre os testes
6. Adicione comentários para testes complexos
