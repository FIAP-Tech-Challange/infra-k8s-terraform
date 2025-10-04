# infra-k8s-terraform

Código Terraform para provisionamento e configuração de infraestrutura Kubernetes, incluindo clusters, namespaces, roles e políticas de rede.

## 📁 Estrutura do Repositório

```
infra-k8s-terraform/
├── main.tf                           # Configuração Terraform principal
├── variables.tf                      # Variáveis globais do projeto
├── README.md                         # Documentação principal
├── run-tests.sh                      # Script para executar todos os testes
├── .gitignore                        # Arquivos ignorados pelo Git
├── .github/workflows/                # CI/CD com GitHub Actions
│   └── gateway-tests.yml            # Pipeline de testes automatizados
├── gateway/                          # Configuração do API Gateway
│   ├── gateway.tf                   # Recursos do Gateway
│   ├── variables.tf                 # Variáveis do Gateway
│   └── authorizer/                  # Lambda Authorizer
│       ├── package.json             # Dependências Node.js
│       ├── package-lock.json        # Lock de dependências
│       ├── jest.config.js           # Configuração do Jest
│       ├── jest.setup.js            # Setup global dos testes
│       ├── .babelrc                 # Configuração Babel (ES modules)
│       ├── TEST_README.md           # Documentação detalhada dos testes
│       ├── src/                     # Código fonte do Authorizer
│       │   ├── index.js             # Handler principal do Lambda
│       │   ├── DatabaseClient.js    # Cliente PostgreSQL
│       │   └── Exception.js         # Classes de exceção
│       ├── __tests__/               # Testes automatizados
│       │   ├── Exception.test.js    # Testes das exceções
│       │   ├── DatabaseClient.test.js # Testes do cliente DB
│       │   ├── index.test.js        # Testes unitários do handler
│       │   └── integration.test.js  # Testes de integração
│       ├── coverage/                # Relatórios de cobertura (gerado)
│       └── iac/                     # Infraestrutura do Authorizer
│           ├── authorizer.tf        # Recursos Terraform
│           └── variables.tf         # Variáveis específicas
└── script/
    └── bootstrap.sh                 # Script de inicialização
```

## 🧪 Executando os Testes

### Método 1: Script Automático (Recomendado)

Execute todos os testes e validações de uma vez:

```bash
# Dar permissão de execução (primeira vez)
chmod +x run-tests.sh

# Executar todos os testes
./run-tests.sh
```

Este script executa:

- ✅ Testes unitários do Authorizer
- ✅ Testes de integração
- ✅ Cobertura de código
- ✅ Validação Terraform
- ✅ Verificação de formatação

### Método 2: Testes Específicos do Gateway Authorizer

```bash
# Navegar para o diretório do authorizer
cd gateway/authorizer

# Instalar dependências (primeira vez)
npm install

# Executar testes
npm test

# Testes em modo watch (desenvolvimento)
npm run test:watch

# Testes com cobertura de código
npm run test:coverage
```

### Método 3: Validação Manual do Terraform

```bash
# Verificar formatação de todos os arquivos
terraform fmt -check -recursive

# Validar configuração principal
terraform init -backend=false
terraform validate

# Validar gateway
cd gateway
terraform init -backend=false
terraform validate

# Validar authorizer IAC
cd authorizer/iac
terraform init -backend=false
terraform validate
```

## 📊 Cobertura de Testes

Os testes do Gateway Authorizer apresentam excelente cobertura:

- ✅ **95.5%** cobertura geral do código
- ✅ **100%** cobertura de funções
- ✅ **87.5%** cobertura de branches
- ✅ **31 testes** passando
- ✅ **4 suítes** de teste

### Tipos de Teste Implementados

1. **Testes Unitários**

   - Validação de tokens
   - Conexão com banco de dados
   - Classes de exceção
   - Handler principal do Lambda

2. **Testes de Integração**

   - Fluxo completo de autorização
   - Cenários de erro
   - Edge cases

3. **Mocks e Simulações**
   - Cliente PostgreSQL
   - Variáveis de ambiente
   - Respostas de banco

## 📈 Relatórios de Cobertura

Após executar os testes com cobertura, acesse:

```bash
# Abrir relatório HTML no navegador
open gateway/authorizer/coverage/lcov-report/index.html

# Ou no Linux
xdg-open gateway/authorizer/coverage/lcov-report/index.html
```

## 🤖 CI/CD Automático

O pipeline do GitHub Actions executa automaticamente quando:

- 📤 Push para `main` ou `develop`
- 🔄 Pull request criado/atualizado
- 📁 Modificações na pasta `gateway/`

### Matriz de Testes

- ✅ Node.js 18.x
- ✅ Node.js 20.x
- ✅ Ubuntu Latest
- ✅ Validação Terraform
- ✅ Upload para Codecov

## 🛠️ Tecnologias Utilizadas

### Infraestrutura

- **Terraform** - Infraestrutura como código
- **AWS Lambda** - Função serverless
- **API Gateway** - Gateway de APIs
- **PostgreSQL** - Banco de dados

### Testes

- **Jest** - Framework de testes
- **Babel** - Transpilação ES modules
- **GitHub Actions** - CI/CD
- **Codecov** - Relatórios de cobertura

## 🚀 Começando

1. **Clone o repositório**

   ```bash
   git clone https://github.com/FIAP-Tech-Challange/infra-k8s-terraform.git
   cd infra-k8s-terraform
   ```

2. **Execute os testes**

   ```bash
   ./run-tests.sh
   ```

3. **Desenvolva com confiança!** 🎉

## TODO - Optional State Locking

For team collaboration and CI/CD safety, consider adding DynamoDB state locking (~$0.25/month cost).

# EKS Cluster com Terraform

Este projeto cria um cluster Amazon EKS usando Terraform.

## 📋 Pré-requisitos

- AWS CLI configurado
- Terraform instalado
- Conta AWS Academy ou permissões adequadas

## 🚀 Como usar

### 1. Configurar variáveis
Edite o arquivo `terraform.tfvars`:
```hcl
# ARN do usuário/role para acesso ao cluster EKS
principal_user_arn = "arn:aws:iam::SUA-CONTA:root"
```

### 2. Aplicar a infraestrutura
```bash
# Inicializar o Terraform
terraform init

# Verificar o plano
terraform plan

# Aplicar as mudanças
terraform apply
```

### 3. Configurar kubectl
Após a criação do cluster, configure o kubectl:

**⚠️ IMPORTANTE: Execute estes comandos na ordem correta:**

```bash
# 1. Configurar credenciais AWS (se necessário)
aws configure list

# 2. Atualizar kubeconfig para o cluster EKS
aws eks update-kubeconfig --region us-east-1 --name eks-tc-3-f106

# 3. Verificar se a configuração funcionou
kubectl config get-contexts

# 4. Testar a conexão
kubectl get svc
```

### 4. Verificar o cluster
```bash
# Verificar nodes (após configurar kubectl)
kubectl get nodes

# Verificar pods do sistema
kubectl get pods -A
```

## 📊 Recursos criados

- **EKS Cluster**: `eks-tc-3-f106`
- **Node Group**: `nodeg-tc-3-f106`
- **Instâncias**: 1-3 nodes t3.medium
- **VPC**: Usa a VPC default da AWS
- **Subnets**: Usa subnets existentes da VPC default

## 🔧 Configurações

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `project_name` | Nome do projeto | `tc-3-f106` |
| `cluster_version` | Versão do Kubernetes | `1.31` |
| `instance_type` | Tipo da instância | `t3.medium` |
| `node_group_desired_size` | Número desejado de nodes | `1` |
| `node_group_max_size` | Número máximo de nodes | `3` |
| `node_group_min_size` | Número mínimo de nodes | `1` |

## 🧹 Limpeza

Para destruir todos os recursos:
```bash
terraform destroy
```

## 📁 Estrutura do projeto

```
├── main.tf              # Configuração principal
├── variables.tf         # Variáveis do projeto
├── outputs.tf          # Outputs
├── providers.tf        # Providers AWS
├── terraform.tfvars    # Valores das variáveis
└── modules/
    └── eks/            # Módulo EKS
        ├── main.tf     # Cluster + Node Group
        ├── variables.tf
        └── outputs.tf
```

## ⚠️ Notas importantes

- **AWS Academy**: Usa `LabRole` existente (sem criar roles IAM)
- **VPC Default**: Utiliza a VPC padrão da conta AWS
- **Subnets**: Usa subnets existentes (sem criar novas)
- **Simplicidade**: Configuração mínima para funcionamento

## 🆘 Troubleshooting

### ❌ Erro: "the server has asked for the client to provide credentials"

**Causa**: kubectl não está configurado corretamente para o cluster EKS.

**Soluções** (tente na ordem):

#### Solução 1 - Reconfiguração básica:
```bash
# 1. Verificar se AWS CLI está configurado
aws sts get-caller-identity

# 2. Reconfigurar kubectl para EKS
aws eks update-kubeconfig --region us-east-1 --name eks-tc-3-f106

# 3. Verificar se funcionou
kubectl get svc
```

## 📚 Comandos úteis

```bash
# Ver informações do cluster
aws eks describe-cluster --name eks-tc-3-f106

# Ver nodes do cluster
kubectl get nodes -o wide

# Ver todos os recursos
kubectl get all -A

# Deletar um pod
kubectl delete pod NOME-DO-POD

# Ver logs de um pod
kubectl logs NOME-DO-POD
```

---
